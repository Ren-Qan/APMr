//
//  LaunchInstrumentsService+Parser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/27.
//

import Foundation

extension LaunchInstrumentsService {
    class Parser {
        enum MainUIThread {
            case none
            case uikit
            case marzipan
            case appkit
        }
        
        var tracePid: UInt32 = 0
        
        private var launchDatapool: [String : LaunchModel] = [:]
        private var mainUIThread: MainUIThread = .none
        private var threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
        
        func parse(data: Data) {
            guard data.count > 0 else {
                return
            }
            
            let version = Data(data.prefix(4))
            if version ==  Data([0x07, 0x58, 0xA2, 0x59]) {
                p1(data)
            } else if version == Data([0x00, 0x02, 0xaa, 0x55]) {
                p2(data)
            } else if version == Data([0x00, 0x03, 0xaa, 0x55]) {
                p2(data)
            } else {
//                p4(data)
            }
        }
    }
}

extension LaunchInstrumentsService.Parser {
    
    enum State {
        case begin
        case end
    }
    
    enum Event: String {
        case none
        case launching
        case initializing
    }
        
    func decode(_ entry: IInstruments.CoreProfileSessionTap.KDEBUGEntry) {
//        let list: [UInt32] = [0x1f, 0x2b, 0x31]
//        if list.contains([entry.class_code]) {
//            decodeAppLifeCycle(entry)
//        } else if entry.debug_id == 835321862 {
//            print("阶段")
//        }
        
        decodeAppLifeCycle(entry)
    }
    
    func decodeAppLifeCycle(_ entry: IInstruments.CoreProfileSessionTap.KDEBUGEntry) {
        guard let process = threadMap[entry.thread], process.pid == tracePid, tracePid != 0 else {
            return
        }
        
        print("[\(process.process) ---\(entry.debug_id) ==== \(entry.class_code) ==== \(entry.subclass_code) === \(entry.action_code) === \(entry.func_code)]")
    }
    
}

extension LaunchInstrumentsService.Parser {
    func p1(_ data: Data) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed, .json5Allowed]) as? [String: Any] {
                print(jsonObject)
            }
        } catch {
            print("Error parsing JSON data: \(error)")
        }
    }
    
    func p2(_ data: Data) {
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
            decode(entry)
        }
        
        stream.close()
    }
    
    func p3(_ data: Data) {
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
    
    func p4(_ data: Data) {
        let stream = InputStream(data: data)
        stream.open()
        
        while stream.hasBytesAvailable {
            var entry = IInstruments.CoreProfileSessionTap.KDEBUGEntry()
            stream.read(&entry, maxLength: 64)
            decode(entry)
        }
        
        stream.close()
    }
}

extension LaunchInstrumentsService.Parser {
    class LaunchModel {
        var event: Event = .none
        var scene: String = ""
        var begin: IInstruments.CoreProfileSessionTap.KDEBUGEntry? = nil
        var end: IInstruments.CoreProfileSessionTap.KDEBUGEntry? = nil
    }
}



