//
//  IInstrumentsCoreProfileSessionTap.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/22.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsCoreProfileSessionTapDelegate: NSObjectProtocol {
    
}

class IInstrumentsCoreProfileSessionTap: IInstrumentsBase {
    public weak var delegate: IInstrumentsCoreProfileSessionTapDelegate? = nil
    private lazy var parser = Parser()
}

extension IInstrumentsCoreProfileSessionTap {
    func set(traceCodes: [Int64 : String]) {
        parser.traceCodes = traceCodes
    }
}

extension IInstrumentsCoreProfileSessionTap: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .coreprofilesessiontap
    }
    
    func response(_ response: DTXReceiveObject) {
        if let dic = response.object as? [String : Any] {
            if let data = (dic["sm"] as? [String : Any])?["ktrace"] as? Data {
                parser.parse(data: data)
            }
        } else if let data = response.object as? Data {
            parser.parse(data: data)
        }
    }
}

extension IInstrumentsCoreProfileSessionTap {
    func start() {
        send(P.start.arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
    
    func setConfig() {
        send(P.setConfig.arg)
    }
}

extension IInstrumentsCoreProfileSessionTap {
    enum P {
        case start
        case stop
        case setConfig
        
        var arg: IInstrumentArgs {
            switch self {
                case .start: return IInstrumentArgs("start")
                case .stop: return IInstrumentArgs("stop")
                case .setConfig:
                    let config: [String: Any] = [
                        "rp": 100,
                        "bm": 1,
                        "tc": [[
                                "kdf2": [735576064, 19202048, 67895296, 835321856, 735838208,
                                         554762240, 730267648, 520552448, 117440512, 19922944,
                                         17563648, 17104896, 17367040, 771686400, 520617984, 20971520, 520421376],
                                "csd": 128,
                                "tk": 3,
                                "ta": [[3], [0], [2], [1, 1, 0]],
                                "uuid": UUID().uuidString.uppercased(),
                            ],
                        ],
                    ]
                    let arg = DTXArguments()
                    arg.append(config)
                    return IInstrumentArgs("setConfig:", dtxArg: arg)
            }
        }
    }
}

extension IInstrumentsCoreProfileSessionTap {
    fileprivate class Parser {
        var traceCodes: [Int64 : String] = [:]
        
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
                p3(data)
            } else {
                p4(data)
            }
        }
    }
}

extension IInstrumentsCoreProfileSessionTap.Parser {
    func p1(_ data: Data) {

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
        
        var threadMap: [UInt64 : KDThreadMap] = [:]
        
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
            let list: [UInt32] = [0x1f, 0x2b, 0x31]
            var entry = KDEBUGEntry()
            stream.read(&entry, maxLength: 64)
            if (list.contains([entry.class_code])) {
                print("======\(threadMap[entry.thread])")
            }
        }
        
        stream.close()
    }
    
    func p3(_ data: Data) {
//        var offset = 0
//        let stream = InputStream(data: data)
//        stream.open()
//
//        let header = UnsafeMutablePointer<KDHeaderV3>.allocate(capacity: 1)
//        offset += stream.read(header, maxLength: MemoryLayout<KDHeaderV3>.size)
//
//        while (stream.hasBytesAvailable) {
//            let subheader = UnsafeMutablePointer<KDSubHeaderV3>.allocate(capacity: 1)
//            offset += stream.read(subheader, maxLength: MemoryLayout<KDSubHeaderV3>.size)
//
//            if let tag = Tag(rawValue: subheader.pointee.tag) {
//                let dataLen = Int(subheader.pointee.length)
//                let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLen)
//                offset += stream.read(dataP, maxLength: dataLen)
//                let subData = Data(bytes: dataP, count: dataLen)
//
//                if let map = try? PropertyListSerialization.propertyList(from: subData, format: nil) as? [String : Any] {
////                    print(map)
//                }
//
//                dataP.deallocate()
//
//                if tag == .kernel || tag == .machine || tag == .config {
//                    var empty: UInt8 = 0
//                    while (offset < data.count && empty == 0) {
//                        empty = UInt8(data[offset])
//                        if empty == 0 {
//                            offset += stream.read(&empty, maxLength: 1)
//                        }
//                    }
//                }
//
//                if tag == .v3RawEvents {
//
//                }
//
//                if tag == .rawVersion3 || tag == .cpuEventsNull {
//                    subheader.deallocate()
//                    continue
//                }
//            }
//            subheader.deallocate()
//        }
//
//        header.deallocate()
//        stream.close()
    }

    func p4(_ data: Data) {
        return
//        let stream = InputStream(data: data)
//        stream.open()
//
//        while stream.hasBytesAvailable {
//            var entry = KDEBUGEntry()
//            stream.read(&entry, maxLength: 64)
//        }
//
//        stream.close()
    }
}



extension IInstrumentsCoreProfileSessionTap.Parser {
    enum Tag: UInt32 {
        case sshot = 0x8002
        case images = 0x8004
        case kernelExtensions = 0x8005
        case config = 0x8006
        case kernel = 0x8008
        case machine = 0x8c00
        case cpuEvents = 0x8c01
        case cpuEvents2 = 0x8013
        case cpuEventsNull = 0x800e
        case rawVersion3 = 0x00001000
        case v3NullChunk = 0x00002000
        case v3Config = 0x00001b00
        case v3CpuHeaderTag = 0x00001c00
        case v3ThreadMap = 0x00001d00
        case v3RawEvents = 0x00001e00
    }
}

extension IInstrumentsCoreProfileSessionTap.Parser {
    struct KDHeaderV3 {
        var tag: UInt32 = 0
        var sub_tag: UInt32 = 0
        var length: UInt64 = 0
        var timebase_numer: UInt32 = 0
        var timebase_denom: UInt32 = 0
        var timestamp: UInt64 = 0
        var walltime_secs: UInt64 = 0
        var walltime_usecs: UInt32 = 0
        var timezone_minuteswest: UInt32 = 0
        var timezone_dst: UInt32 = 0
        var flags: UInt32 = 0
    }
        
    struct KDSubHeaderV3 {
        var tag: UInt32 = 0
        var major: UInt16 = 0
        var minor: UInt16 = 0
        var length: UInt64 = 0
    }
    
    struct KDCpuMapHeader {
        var version: UInt32 = 0
        var count: UInt32 = 0
    }
    
    struct KDCpuMap {
        var cpuId: UInt32 = 0
        var flags: UInt32 = 0
        var name = Data(capacity: 8)
        var args = Array<UInt32>(repeating: 0, count: 6)
    }
    
    struct KDHeaderV2 {
        var tag: UInt32 = 0
        var number_of_treads: UInt32 = 0
        var arg1: Int32 = 0
        var arg2: Int32 = 0
        var arg3: Int32 = 0
        var is_64bit: UInt32 = 0
        var tick_frequency: UInt64 = 0
    }
    
    struct KDThreadMap {
        var thread: UInt64 = 0
        var pid: UInt32 = 0
        var process = String()
    }
    
    struct KDEBUGEntry {
        var timestamp: UInt64 = 0
        var arg1: UInt64 = 0
        var arg2: UInt64 = 0
        var arg3: UInt64 = 0
        var arg4: UInt64 = 0
        var thread: UInt64 = 0
        var debug_id: UInt32 = 0
        var unused: UInt32 = 0
        var cpu_id: UInt64 = 0
        
        var event_id: UInt32 { debug_id & UInt32(0xfffffffc) }
        var func_code: UInt32 { debug_id & UInt32(0x00000003) }
        var class_code: UInt32 { (debug_id & UInt32(0xff000000)) >> 24 }
        var subclass_code: UInt32 { (debug_id & UInt32(0x00ff0000)) >> 16 }
        var final_code: UInt32 { (debug_id & UInt32(0x0000fffc)) >> 2 }
    }
}


