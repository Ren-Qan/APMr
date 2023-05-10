//
//  Processcontrol.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsProcesscontrolDelegate: NSObjectProtocol {
    func launch(pid: UInt32)
    
    func outputReceived(_ msg: String)
}

extension IInstrumentsProcesscontrolDelegate {
    func launch(pid: UInt32) { }
    
    func outputReceived(_ msg: String) { }
}

extension IInstruments {
    class Processcontrol: Base {
        public weak var delegate: IInstrumentsProcesscontrolDelegate? = nil
        
        private var pid: UInt32 = 0
        private var launchConfig: LaunchConfig? = nil
    }
}

extension IInstruments.Processcontrol {
    func launch(bundle: String) {
        let config = LaunchConfig.common(bundle: bundle)
        launch(config: config)
    }
    
    func launch(config: LaunchConfig) {
        self.launchConfig = config
        send(P.launch(config: config).arg)
    }
    
    func kill(pid: UInt32) {
        self.pid = pid
        send(P.kill(pid: pid).arg)
    }
}

extension IInstruments.Processcontrol: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .processcontrol
    }
    
    func response(_ response: IInstruments.R) {
        if response.flag == 2,
           let message = response.array?.first as? String {
            delegate?.outputReceived(message)
        } else if let pid = response.object as? UInt32 {
            delegate?.launch(pid: pid)
        }
    }
}

extension IInstruments.Processcontrol {
    struct LaunchConfig {
        var devicePath = ""
        var bundle: String
        var environment: [String : Any] = [:]
        var arguments: [String : Any] = [:]
        var options: [String : Any] = [:]
        
        static func common(_ path: String = "",
                           _ container: String = "",
                           bundle: String,
                           killExisting: Bool = true) -> LaunchConfig {
            let item = LaunchConfig(bundle: bundle,
                                    options: ["StartSuspendedKey": false, "KillExisting": killExisting])
            return item
        }
    }
    
    enum P {
        case launch(config: LaunchConfig)
        
        case kill(pid: UInt32)
        
        var arg: IInstrumentArgs {
            switch self {
                case .launch(let config):
                    let selector = "launchSuspendedProcessWithDevicePath:bundleIdentifier:environment:arguments:options:"
                    let dtx = DTXArguments()
                    dtx.append(config.devicePath)
                    dtx.append(config.bundle)
                    dtx.append(config.environment)
                    dtx.append(config.arguments)
                    dtx.append(config.options)
                    
                    let arg = IInstrumentArgs(selector,
                                              dtxArg: dtx)
                    
                    return arg
                    
                case .kill(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs("killPid:",
                                           dtxArg: arg)
            }
        }
    }
}
