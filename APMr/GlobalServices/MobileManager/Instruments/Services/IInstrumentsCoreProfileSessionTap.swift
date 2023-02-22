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
                case .start: return IInstrumentArgs(padding: 1, selector: "start")
                case .stop: return IInstrumentArgs(padding: 2, selector: "stop")
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
                    return IInstrumentArgs(padding: 3, selector: "setConfig:", dtxArg: arg)
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
        let header = KDHeaderV3(data: data)
        print(data)
    }
    
    func p4(_ data: Data) {
        
    }
}

extension IInstrumentsCoreProfileSessionTap.Parser {
    struct KDHeaderV3: Codable {
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
        
        init?(data: Data) {
            let count = MemoryLayout<KDHeaderV3>.size
            let result = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Bool in
                guard bytes.count >= count else {
                    return false
                }
                let rawPointer = bytes.baseAddress!
                let typedPointer = rawPointer.assumingMemoryBound(to: KDHeaderV3.self)
                self = typedPointer.pointee
                return true
            }
            
            if !result {
                return nil
            }
        }
    }
}
