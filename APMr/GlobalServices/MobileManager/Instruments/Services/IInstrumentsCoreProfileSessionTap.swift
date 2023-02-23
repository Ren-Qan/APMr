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
        var data: Data? = nil
    }
    
    struct KDCpuMapHeader {
        var version: UInt32 = 0
        var count: UInt32 = 0
    }
}


