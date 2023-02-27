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
        
        var traceCodes: [Int64 : String] = [:]
        var machInfo: [Any] = []
        var usecs_since_epoch: TimeInterval = 0
        
        private var launchDatapool: [String : LaunchModel] = [:]
        private var mainUIThread: MainUIThread = .none
        private var threadMap: [UInt64 : KDThreadMap] = [:]
        
        private var last: Int64 = -1
        private var start: Int64 = 0
        
        func parse(data: Data) {
            guard data.count > 0 else {
                return
            }
            
            let version = Data(data.prefix(4))
            
            if version ==  Data([0x07, 0x58, 0xA2, 0x59]) {
//                p1(data)
            } else if version == Data([0x00, 0x02, 0xaa, 0x55]) {
                p2(data)
            } else if version == Data([0x00, 0x03, 0xaa, 0x55]) {
                // p3(data)
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
    
    func record(_ state: State,
                event: Event,
                scene: String,
                entry: KDEBUGEntry) {
        let key = event.rawValue + "-" + scene
        var item = launchDatapool[key]
        if item == nil {
            item = LaunchModel()
            item?.event = event
            item?.scene = scene
            launchDatapool[key] = item
        }
        
        if state == .begin {
            item?.begin = entry
        } else {
            item?.end = entry
        }
    }
    
    func decode(_ entry: KDEBUGEntry) {
        var time: Int64 {
            guard machInfo.count > 0 else {
                return -1
            }
            let time = Int64(entry.timestamp - UInt64(machInfo[0] as! Int64)) * (machInfo[1] as! Int64) / (machInfo[2] as! Int64)
            return time
        }
        
        let list: [UInt32] = [0x1f, 0x2b, 0x31]
        if list.contains([entry.class_code]),
           let process = threadMap[entry.thread] {
            print("==========")
            print(process)
            print(entry)
//            print(time())
            if last < 0 {
                last = time
                start = last
            } else {
                let t = time
                print("\(t - last) --- \(t - start)")
                last = t
            }
            
//            decodeAppLifeCycle(entry)
        } else if entry.debug_id == 835321862 {
            
        }
    }
    
    func decodeAppLifeCycle(_ entry: KDEBUGEntry) {
        func write(_ state: State, _ event: Event, _ scene: String) {
            print("====\(event.rawValue)====\(scene)====\(state)")
            record(state, event: event, scene: scene, entry: entry)
        }
        
        if entry.class_code == 0x1f { // dyld-init
            if entry.subclass_code == 0x7,
               entry.final_code == 13 {
                write(.begin, .initializing, "System Interface Initialization (Dyld init)")
            } else if entry.subclass_code == 0x7,
                      entry.final_code == 1,
                      entry.func_code == 2 {
                write(.end, .initializing, "Static Runtime Initialization")
            }
        } else if entry.class_code == 0x31 {// AppKit/UIKit common application launch phases
            if entry.subclass_code == 0xca,
               entry.final_code == 1,
               entry.func_code == 2 {
                write(.end, .launching, "Initial Frame Rendering")
            }
        } else if entry.class_code == 0x2b {
            
            if entry.subclass_code == 0xd8 { //appkit-init
                if entry.final_code == 1, entry.func_code == 0 {
                    if mainUIThread == .none {
                        write(.begin, .launching, "AppKit Initialization")
                        mainUIThread = .uikit
                    } else if mainUIThread == .uikit {
                        write(.end, .launching, "UIKit Initialization")
                        write(.begin, .launching, "AppKit Initialization")
                        mainUIThread = .marzipan
                    }
                } else if entry.final_code == 12, entry.func_code == 0 {
                    write(.end, .launching, "AppKit Initialization")
                    write(.begin, .launching, "AppKit Scene Creation")
                } else if entry.final_code == 12, entry.func_code == 1 {
                    write(.end, .launching, "AppKit Scene Creation")
                    write(.begin, .launching, "applicationWillFinishLaunching()")
                } else if entry.final_code == 12, entry.func_code == 2 {
                    write(.end, .launching, "applicationWillFinishLaunching()")
                    write(.begin, .launching, "AppKit Scene Creation")
                } else if entry.final_code == 11, entry.func_code == 1 {
                    write(.end, .launching, "AppKit Scene Creation")
                    write(.begin, .launching, "applicationDidFinishLaunching()")
                } else if entry.final_code == 11, entry.func_code == 2 {
                    if mainUIThread == .appkit {
                        write(.end, .launching, "applicationDidFinishLaunching()")
                        write(.begin, .launching, "Initial Frame Rendering")
                    } else if mainUIThread == .marzipan {
                        write(.end, .launching, "applicationDidFinishLaunching()")
                        write(.begin, .launching, "AppKit Scene Creation")
                    }
                }
            } else if entry.subclass_code == 0x87 { // UIKit application launch phases
                if entry.final_code == 90, entry.arg1 == 0x32 {
                    write(.begin, .launching, "UIKit Initialization")
                    mainUIThread = .uikit
                } else if entry.final_code == 21 {
                    if mainUIThread == .uikit {
                        write(.end, .launching, "UIKit Initialization")
                        write(.begin, .launching, "UIKit Scene Creation")
                    } else if mainUIThread == .marzipan {
                        write(.end, .initializing, "AppKit Scene Creation")
                        write(.begin, .initializing, "UIKit Scene Creation")
                    }
                } else if entry.final_code == 23 {
                    write(.end, .launching, "UIKit Scene Creation")
                    write(.begin, .launching, "willFinishLaunchingWithOptions()")
                } else if entry.final_code == 24 {
                    write(.end, .launching, "willFinishLaunchingWithOptions()")
                    write(.begin, .launching, "UIKit Scene Creation")
                } else if entry.final_code == 25 {
                    write(.end, .launching, "UIKit Scene Creation")
                    write(.begin, .launching, "didFinishLaunchingWithOptions()")
                } else if entry.final_code == 26 {
                    write(.end, .launching, "didFinishLaunchingWithOptions()")
                    write(.begin, .launching, "UIKit Scene Creation")
                } else if entry.final_code == 300 {
                    write(.end, .launching, "UIKit Scene Creation")
                    write(.begin, .launching, "sceneWillConnectTo()")
                } else if entry.final_code == 301 {
                    write(.end, .launching, "UIKit Scene Creation")
                    write(.begin, .launching, "sceneWillEnterForeground()")
                } else if entry.final_code == 313 {
                    write(.end, .launching, "sceneWillEnterForeground()")
                    write(.begin, .launching, "UIKit Scene Creation")
                } else if entry.final_code == 12 {
                    write(.end, .launching, "UIKit Scene Creation")
                    write(.begin, .launching, "Initial Frame Rendering")
                }
            } else if entry.subclass_code == 0xdc { // appkit-init
                if entry.final_code == 12,
                   entry.func_code == 0,
                   entry.arg1 == 10 {
                    write(.end, .initializing, "System Interface Initialization (Dyld init)")
                    write(.begin, .initializing, "Static Runtime Initialization")
                }
            }
        }
    }
    
}

extension LaunchInstrumentsService.Parser {
    func p1(_ data: Data) {
        p4(data)
    }
    
    func p2(_ data: Data) {
        let stream = InputStream(data: data)
        stream.open()
        
        var header = KDHeaderV2()
        stream.read(&header, maxLength: MemoryLayout<KDHeaderV2>.size)
        
        let empty = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x100)
        stream.read(empty, maxLength: 0x100)
        empty.deallocate()
        
        let mapCount = Int(header.number_of_treads)
        var threadI = 0
        
        while stream.hasBytesAvailable, threadI < mapCount {
            var thread = KDThreadMap()
            
            stream.read(&thread.thread, maxLength: 8)
            stream.read(&thread.pid, maxLength: 4)
            
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
            
            thread.process = String(cString: cString)
            threadI += 1
            threadMap[thread.thread] = thread
        }
        
        while stream.hasBytesAvailable {
            var entry = KDEBUGEntry()
            stream.read(&entry, maxLength: 64)
            decode(entry)
        }
        
        stream.close()
    }
    
    func p3(_ data: Data) {
        var offset = 0
        let stream = InputStream(data: data)
        stream.open()
        
        let header = UnsafeMutablePointer<KDHeaderV3>.allocate(capacity: 1)
        offset += stream.read(header, maxLength: MemoryLayout<KDHeaderV3>.size)
        
        while (stream.hasBytesAvailable) {
            let subheader = UnsafeMutablePointer<KDSubHeaderV3>.allocate(capacity: 1)
            offset += stream.read(subheader, maxLength: MemoryLayout<KDSubHeaderV3>.size)
            
            if let tag = Tag(rawValue: subheader.pointee.tag) {
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
            var entry = KDEBUGEntry()
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
        var begin: KDEBUGEntry? = nil
        var end: KDEBUGEntry? = nil
    }
}



