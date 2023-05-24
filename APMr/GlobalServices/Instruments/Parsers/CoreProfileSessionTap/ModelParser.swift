//
//  CoreProfileSessionTap+Parser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/9.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    class Parser {
        weak var delegate: IInstrumentsCoreProfileSessionTapDelegate? = nil
        
        private lazy var kParser = KTParser()
        private lazy var dParser = KDebugParser()
        
        public func parse(_ data: Data) {
            guard data.count > 0 else {
                return
            }

            let version = Data(data.prefix(4))
            if version == Data([0x07, 0x58, 0xA2, 0x59]) {
                delegate?.parserV1(kParser.parse(data))
            } else if version == Data([0x00, 0x02, 0xaa, 0x55]) {
                delegate?.parserV2(dParser.parseV2(data))
            } else if version == Data([0x00, 0x03, 0xaa, 0x55]) {
                delegate?.parserV3(dParser.parseV3(data))
            } else {
                delegate?.parserV4(dParser.parseNormal(data))
            }
        }
    }
}

extension IInstruments.CoreProfileSessionTap {
    class KTParser {
        func parse(_ data: Data) -> ModelV1 {
            var elements = [KCData]()
            var offset = 0
            let stream = InputStream(data: data)
            stream.open()
            
            while stream.hasBytesAvailable {
                var type: UInt32 = 0
                var size: UInt32 = 0
                var flag: UInt64 = 0
                
                offset += stream.read(&type, maxLength: 4)
                offset += stream.read(&size, maxLength: 4)
                offset += stream.read(&flag, maxLength: 8)
                let data = stream.data(Int(size))
                
                var kt = IInstruments.CoreProfileSessionTap.KT.KCDATA_TYPE_INVALID
                if let k = IInstruments.CoreProfileSessionTap.KT(rawValue: type) {
                    kt = k
                }
                
                let item = IInstruments.CoreProfileSessionTap.KCData(type: kt,
                                                                     size: size,
                                                                     flag: flag,
                                                                     data: data)
                elements.append(item)
            }
            
            stream.close()
            return ModelV1(elements: elements)
        }
    }
}

extension IInstruments.CoreProfileSessionTap {
    class KDebugParser {
        func parseV2(_ data: Data) -> ModelV2 {
            var threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
            var elements: [IInstruments.CoreProfileSessionTap.KDEBUGElement] = []
                        
            let stream = InputStream(data: data)
            stream.open()
            
            var tag: UInt32 = 0
            var numberOfThread: UInt32 = 0
            var arg1: UInt64 = 0
            var arg2: UInt32 = 0
            var is64b: UInt32 = 0
            var tick_frequency: UInt64 = 0

            stream.read(&tag, maxLength: 4)
            stream.read(&numberOfThread, maxLength: 4)
            stream.read(&arg1, maxLength: 8)
            stream.read(&arg2, maxLength: 4)
            stream.read(&is64b, maxLength: 4)
            stream.read(&tick_frequency, maxLength: 8)
            
            let header = IInstruments
                .CoreProfileSessionTap
                .KDHeaderV2(tag: tag,
                            number_of_treads: numberOfThread,
                            is_64bit: is64b,
                            tick_frequency: tick_frequency)
            
            
            let _ = stream.data(0x100)

            let mapCount = Int(header.number_of_treads)
            var threadI = 0
            
            while stream.hasBytesAvailable, threadI < mapCount {
                var thread: UInt64 = 0
                var pid: UInt32 = 0
                var process = ""
                
                stream.read(&thread, maxLength: 8)
                stream.read(&pid, maxLength: 4)
                
                let cStringsData = UnsafeMutablePointer<UInt8>.allocate(capacity: 20)
                stream.read(cStringsData, maxLength: 20)
                
                var i = 0
                var cString = [UInt8]()
                while i < 20, (cStringsData + i).pointee != 0 {
                    cString.append((cStringsData + i).pointee)
                    i += 1
                }
                cString.append(0)
                cStringsData.deallocate()
                process = String(cString: cString)

            
                threadMap[thread] = IInstruments
                    .CoreProfileSessionTap
                    .KDThreadMap(thread: thread,
                                 pid: pid,
                                 process: process)
                threadI += 1
            }
            
            while stream.hasBytesAvailable {
                var timestamp: UInt64 = 0
                let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
                var thread: UInt64 = 0
                var debug: UInt32 = 0
                var cpu: UInt32 = 0
                var unused: UInt64 = 0
                
                stream.read(&timestamp, maxLength: 8)
                stream.read(dataP, maxLength: 32)
                stream.read(&thread, maxLength: 8)
                stream.read(&debug, maxLength: 4)
                stream.read(&cpu, maxLength: 4)
                stream.read(&unused, maxLength: 8)
                
                let data = Data(bytes: dataP, count: 32)
                dataP.deallocate()
                
                let element = IInstruments
                    .CoreProfileSessionTap
                    .KDEBUGElement(timestamp: timestamp,
                                 data: data,
                                 thread: thread,
                                 debug_id: debug,
                                 cpu_id: cpu,
                                 unused: unused)
                if element.timestamp != 0 {
                    elements.append(element)
                }
            }
            
            stream.close()
            
            return ModelV2(threadMap: threadMap,
                           elements: elements)
        }
        
        func parseV3(_ data: Data) -> ModelV3 {
            var elements = [KDSubHeaderV3]()
            let stream = InputStream(data: data)
            stream.open()
            
            let headV3 = KDHeaderV3(stream)
            var fSpace = Int(headV3.length - 40)
            
            while(stream.hasBytesAvailable) {
                let subheader = KDSubHeaderV3(stream)
                elements.append(subheader)
                var padding = 0
                if fSpace > 0 {
                    padding = fSpace - 16 - Int(subheader.length)
                    fSpace = 0
                } else {
                    padding = Int((subheader.length + 16) % 8)
                    if padding > 0 {
                        padding = 8 - padding
                    }
                }
                if padding > 0 {
                    let _ = stream.data(padding)
                }
            }

            stream.close()
            return .init(elements: elements)
        }
        
        func parseNormal(_ data: Data) -> ModelV4 {
            var elements = [IInstruments.CoreProfileSessionTap.KDEBUGElement]()
            let stream = InputStream(data: data)
            stream.open()
            
            while stream.hasBytesAvailable {
                var timestamp: UInt64 = 0
                var thread: UInt64 = 0
                var debug: UInt32 = 0
                var cpu: UInt32 = 0
                var unused: UInt64 = 0
                
                stream.read(&timestamp, maxLength: 8)
                let data = stream.data(32)
                stream.read(&thread, maxLength: 8)
                stream.read(&debug, maxLength: 4)
                stream.read(&cpu, maxLength: 4)
                stream.read(&unused, maxLength: 8)
                
                let element = IInstruments
                    .CoreProfileSessionTap
                    .KDEBUGElement(timestamp: timestamp,
                                 data: data,
                                 thread: thread,
                                 debug_id: debug,
                                 cpu_id: cpu,
                                 unused: unused)
                elements.append(element)
            }
            
            stream.close()
            return ModelV4(elements: elements)
        }
    }
}


