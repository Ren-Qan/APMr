//
//  CoreProfileSessionTap.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/22.
//

import Foundation
import LibMobileDevice

protocol IInstrumentsCoreProfileSessionTapDelegate: NSObjectProtocol {
    func praserV1(_ model: IInstruments.CoreProfileSessionTap.ModelV1)
    func praserV2(_ model: IInstruments.CoreProfileSessionTap.ModelV2)
    func praserV4(_ model: IInstruments.CoreProfileSessionTap.ModelV4)
}

extension IInstruments {
    class CoreProfileSessionTap: Base {
        private lazy var parser = Parser()
        
        public weak var delegate: IInstrumentsCoreProfileSessionTapDelegate? = nil {
            didSet {
                parser.delegate = delegate
            }
        }
    }
}

extension IInstruments.CoreProfileSessionTap: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .coreprofilesessiontap
    }
    
    func response(_ response: IInstruments.R) {
        if let dic = response.object as? [String : Any] {
            if let data = (dic["sm"] as? [String : Any])?["ktrace"] as? Data {
                parse(data)
            }
        } else if let data = response.object as? Data {
            parse(data)
        }
    }
    
    private func parse(_ data: Data) {
        parser.parse(data)
    }
}

extension IInstruments.CoreProfileSessionTap {
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

extension IInstruments.CoreProfileSessionTap {
    enum P {
        case start
        case stop
        case setConfig
        
        var arg: IInstrumentArgs {
            switch self {
                case .start: return IInstrumentArgs("start")
                case .stop: return IInstrumentArgs("stop")
                case .setConfig:
                    let config: [String : Any] =
                    [
                        "tc": [
                            [
                                "kdf2": [735576064, 19202048, 67895296, 835321856, 735838208, 554762240,
                                         730267648, 520552448, 117440512, 19922944, 17563648, 17104896, 17367040,
                                         771686400, 520617984, 20971520, 520421376],
                                "csd": 128,
                                "tk": 3,
                                "ta": [[3], [0], [2], [1, 1, 0]],
                                "uuid": UUID().uuidString.uppercased(),
                            ] as [String : Any],
                            [
                                "tsf": [65537],
                                "ta": [[0], [2], [1, 1, 0]],
                                "si": 5000000,
                                "tk": 1,
                                "uuid": UUID().uuidString.uppercased(),
                            ],
                        ],
                        "rp": 100,
                        "bm": 1,
                    ]
                    let arg = DTXArguments()
                    arg.append(config)
                    return IInstrumentArgs("setConfig:", dtxArg: arg)
            }
        }
    }
}

