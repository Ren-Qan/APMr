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
            
            var offset = 0
            
            let stream = InputStream(data: data)
            stream.open()
            
            var header = IInstruments.CoreProfileSessionTap.KDHeaderV2()
            offset += stream.read(&header, maxLength: MemoryLayout<IInstruments.CoreProfileSessionTap.KDHeaderV2>.size)
            
            let empty = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x100)
            offset += stream.read(empty, maxLength: 0x100)
            empty.deallocate()
            
            let mapCount = Int(header.number_of_treads)
            var threadI = 0
            
            while stream.hasBytesAvailable, threadI < mapCount {
                var thread = IInstruments.CoreProfileSessionTap.KDThreadMap()
                
                offset += stream.read(&thread.thread, maxLength: 8)
                offset += stream.read(&thread.pid, maxLength: 4)
                
                let cStringsData = UnsafeMutablePointer<UInt8>.allocate(capacity: 20)
                offset += stream.read(cStringsData, maxLength: 20)
                var i = 0
                var cString = [UInt8]()
                while i < 20, (cStringsData + i).pointee != 0 {
                    cString.append((cStringsData + i).pointee)
                    i += 1
                }
                cString.append(0)
                cStringsData.deallocate()
                
                thread.process = String(cString: cString)
                threadI += 1
                threadMap[thread.thread] = thread
            }
            
            var e: UInt8 = 0
            while (offset < data.count && e == 0) {
                e = UInt8(data[offset])
                if e == 0 {
                    offset += stream.read(&e, maxLength: 1)
                }
            }
            
            while stream.hasBytesAvailable {
                var entry = IInstruments.CoreProfileSessionTap.KDEBUGEntry()
                stream.read(&entry, maxLength: 64)
                entries.append(entry)
            }
            
            stream.close()
            
            return ModelV2(threadMap: threadMap,
                           entries: entries)
        }
        
        func parseV3(_ data: Data) {
            var offset = 0
            let stream = InputStream(data: data)
            stream.open()
            
            let header = UnsafeMutablePointer<IInstruments.CoreProfileSessionTap.KDHeaderV3>.allocate(capacity: 1)
            offset += stream.read(header, maxLength: MemoryLayout<IInstruments.CoreProfileSessionTap.KDHeaderV3>.size)
            
            while (stream.hasBytesAvailable) {
                let subheader = UnsafeMutablePointer<IInstruments.CoreProfileSessionTap.KDSubHeaderV3>.allocate(capacity: 1)
                offset += stream.read(subheader, maxLength: MemoryLayout<IInstruments.CoreProfileSessionTap.KDSubHeaderV3>.size)
                
                if let tag = IInstruments.CoreProfileSessionTap.Tag(rawValue: subheader.pointee.tag) {
                    let dataLen = Int(subheader.pointee.length)
                    let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLen)
                    offset += stream.read(dataP, maxLength: dataLen)
                    let subData = Data(bytes: dataP, count: dataLen)
                    
                    if let map = try? PropertyListSerialization.propertyList(from: subData, format: nil) as? [String : Any] {
                        print(map)
                    }
                    
                    dataP.deallocate()
                    
                    if tag == .kernel || tag == .machine || tag == .config {
                        var empty: UInt8 = 0
                        while (offset < data.count && empty == 0) {
                            empty = UInt8(data[offset])
                            if empty == 0 {
                                offset += stream.read(&empty, maxLength: 1)
                            }
                        }
                    }
                    
                    if tag == .v3RawEvents {
                        
                    }
                    
                    if tag == .rawVersion3 || tag == .cpuEventsNull {
                        subheader.deallocate()
                        continue
                    }
                }
                subheader.deallocate()
            }
            
            header.deallocate()
            stream.close()
        }
        
        func parseNormal(_ data: Data) -> ModelV4 {
            var entries = [IInstruments.CoreProfileSessionTap.KDEBUGEntry]()
            let stream = InputStream(data: data)
            stream.open()
            
            while stream.hasBytesAvailable {
                var entry = IInstruments.CoreProfileSessionTap.KDEBUGEntry()
                stream.read(&entry, maxLength: 64)
                entries.append(entry)
            }
            
            stream.close()
            return ModelV4(entries: entries)
        }
    }
}
