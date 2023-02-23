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

extension IInstrumentsCoreProfileSessionTap: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .coreprofilesessiontap
    }
    
    func response(_ response: DTXReceiveObject) {
        if let dic = response.object as? [String : Any] {
            if let data = (dic["sm"] as? [String : Any])?["ktrace"] as? Data {
                parser.parse(data: data)
            }
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
                    "tc": [
                        [
                            "kdf2": Set([735576064, 19202048, 67895296, 835321856, 735838208,
                                         554762240, 730267648, 520552448, 117440512, 19922944,
                                         17563648, 17104896, 17367040, 771686400, 520617984, 20971520, 520421376]),
                            "csd": 128,
                            "tk": 3,
                            "ta": [
                                [3],
                                [0],
                                [2],
                                [1, 1, 0]
                            ],
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
        private var traces: [Any] = []
        
        func parse(data: Data) {
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
        
    }
    
    func p3(_ data: Data) {
        let input = InputStream(data: data)
        input.open()
        
        var offset = 0
        var header = KDHeaderV3()
        offset += input.read(&header, maxLength: MemoryLayout<KDHeaderV3>.size)
        
        func readEmpty() {
            var empty: UInt8 = 0
            while (offset < data.count && empty == 0) {
                empty = UInt8(data[offset])
                if empty == 0 {
                    offset += input.read(&empty, maxLength: 1)
                }
            }
        }
        
        while input.hasBytesAvailable {
            print("===========")
            var pack = KTracePack()
            offset += input.read(&pack, maxLength: MemoryLayout<KTracePack>.size)
            
            print(pack)
            
            let len = Int(pack.length)
            var pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
            offset += input.read(pointer, maxLength: len)
            let packData = Data(bytes: pointer, count: len)
            pointer.deallocate()
            
            print(packData)
            
            guard let tag = Tag(rawValue: pack.tag) else {
                break
            }
            
            switch tag {
                case .cpuEventsNull: continue
                case .v3NullChunk: continue
                case .config:
                    print("config")
                    do {
                        let dic = try PropertyListSerialization.propertyList(from: packData,
                                                                             options: .mutableContainersAndLeaves,
                                                                             format: nil)
                        print(dic)
                    } catch { }
                    readEmpty()
                case .sshot:
                    print("sshot")
                case .kernel:
                    print("kernel")
                    readEmpty()
                case .machine:
                    print("machine")
                    do {
                        let dic = try PropertyListSerialization.propertyList(from: packData,
                                                                             options: .mutableContainersAndLeaves,
                                                                             format: nil)
                        print(dic)
                    } catch { }
                    
                    readEmpty()
                case .v3CpuHeaderTag:
                    let len = Int(pack.length) - MemoryLayout<KDCpuMapHeader>.size
                    var i = 0
                    
                    while i < len {
                        var cpuInfo = KDCpuMap()
                        print(cpuInfo)
                        i += input.read(&cpuInfo, maxLength: MemoryLayout<KDCpuMap>.size)
                    }
                    offset += len
                    print("v3CpuHeaderTag")
                case .v3ThreadMap:
                    print("setThread")
                case .v3RawEvents:
                    print("setThread")
                default: continue
            }
        }
        
        
        input.close()
    }
    
    func p4(_ data: Data) {
        
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
    
    struct KTracePack {
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
}



