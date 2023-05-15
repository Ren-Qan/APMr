//
//  CoreProfileSessionTap+KDebug.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/9.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    class KDebugParser {
        func parseV2(_ data: Data) -> ModelV2 {
            var threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
            var entries: [IInstruments.CoreProfileSessionTap.KDEBUGEntry] = []
                        
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
            
            
            let empty = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x100)
            stream.read(empty, maxLength: 0x100)
            empty.deallocate()
            
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
                
                let entry = IInstruments
                    .CoreProfileSessionTap
                    .KDEBUGEntry(timestamp: timestamp,
                                 data: data,
                                 thread: thread,
                                 debug_id: debug,
                                 cpu_id: cpu,
                                 unused: unused)
                if entry.timestamp != 0 {
                    entries.append(entry)
                }
            }
            
            stream.close()
            
            return ModelV2(threadMap: threadMap,
                           entries: entries)
        }
        
        func parseV3(_ data: Data) -> ModelV3 {
            var entries = [KDSubHeaderV3]()
            let stream = InputStream(data: data)
            stream.open()
            
            let headV3 = KDHeaderV3(stream)
            var fSpace = Int(headV3.length - 40)
            
            while(stream.hasBytesAvailable) {
                let subheader = KDSubHeaderV3(stream)
                entries.append(subheader)
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
            return .init(entries: entries)
        }
        
        func parseNormal(_ data: Data) -> ModelV4 {
            var entries = [IInstruments.CoreProfileSessionTap.KDEBUGEntry]()
            let stream = InputStream(data: data)
            stream.open()
            
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
                                
                let entry = IInstruments
                    .CoreProfileSessionTap
                    .KDEBUGEntry(timestamp: timestamp,
                                 data: data,
                                 thread: thread,
                                 debug_id: debug,
                                 cpu_id: cpu,
                                 unused: unused)
                entries.append(entry)
            }
            
            stream.close()
            return ModelV4(entries: entries)
        }
    }
}

extension InputStream {
    func data(_ len: Int) -> Data {
        guard len > 0 else {
            return .init()
        }
        let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        read(dataP, maxLength: len)
        let data = Data(bytes: dataP, count: len)
        dataP.deallocate()
        return data
    }
}



