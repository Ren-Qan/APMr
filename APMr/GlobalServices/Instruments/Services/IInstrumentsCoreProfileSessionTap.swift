//
//  IInstrumentsCoreProfileSessionTap.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/22.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsCoreProfileSessionTapDelegate: NSObjectProtocol {
    func launch(data: Data)
}

class IInstrumentsCoreProfileSessionTap: IInstrumentsBase {
    public weak var delegate: IInstrumentsCoreProfileSessionTapDelegate? = nil
}


extension IInstrumentsCoreProfileSessionTap: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .coreprofilesessiontap
    }
    
    func response(_ response: DTXReceiveObject) {
        if let dic = response.object as? [String : Any] {
            if let data = (dic["sm"] as? [String : Any])?["ktrace"] as? Data {
                delegate?.launch(data: data)
            }
        } else if let data = response.object as? Data {
            delegate?.launch(data: data)
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
                    let config: [String: Any] =
                    [
                        "rp": 100,
                        "bm": 1,
                        "tc": [
                            [
                                "kdf2": [735576064, 19202048, 67895296, 835321856, 735838208, 554762240,
                                         730267648, 520552448, 117440512, 19922944, 17563648, 17104896, 17367040,
                                         771686400, 520617984, 20971520, 520421376],
                                "csd": 128,
                                "tk": 3,
                                "ta": [[3], [0], [2], [1, 1, 0]],
                                "uuid": UUID().uuidString.uppercased(),
                            ],
                            [
                                "tsf": [65537],
                                "ta": [[0], [2], [1, 1, 0]],
                                "si": 5000000,
                                "tk": 1,
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
