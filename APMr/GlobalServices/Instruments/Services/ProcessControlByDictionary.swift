//
//  ProcessControlByDictionary.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/16.
//

import Foundation
import LibMobileDevice

protocol IInstrumentsProcessControlByDictionaryDelegate: NSObjectProtocol {
    func launch(pid: PID)
}

extension IInstrumentsProcessControlByDictionaryDelegate {
    func launch(pid: PID) { }
}

extension IInstruments {
    class ProcessControlByDictionary: Base {
        public weak var delegate: IInstrumentsProcessControlByDictionaryDelegate? = nil
        
        private var launchConfig: LaunchConfig? = nil
        private var startPid: PID = 0
        private var stopPid: PID = 0
        private var resumePid: PID = 0
    }
}

extension IInstruments.ProcessControlByDictionary {
    func launch(config: LaunchConfig) {
        self.launchConfig = config
        send(P.launch(config: config).arg)
    }
    
    func start(pid: PID) {
        self.startPid = pid
        send(P.start(pid: pid).arg)
    }
    
    func stop(pid: PID) {
        self.stopPid = pid
        send(P.stop(pid: pid).arg)
    }
    
    func resume(pid: PID) {
        self.resumePid = pid
    }
}

extension IInstruments.ProcessControlByDictionary: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .pcbd
    }
    
    func response(_ response: IInstruments.R) {        
        if let pid = response.object as? PID {
            delegate?.launch(pid: pid)
        }
    }
}

extension IInstruments.ProcessControlByDictionary {
    struct LaunchConfig {
        var devicePath: String
        var bundle: String
        var environment: [String : Any] = [:]
        var args: [Any] = []
        var options: [String : Any] = [:]
        
        static func common(path: String, bundle: String, env: [String : Any]) -> LaunchConfig {
            let options: [String : Any] = ["StartSuspendedKey": 0, "KillExisting": true]
            return LaunchConfig(devicePath: path, bundle: bundle, environment: env, options: options)
        }
    }
    
    enum P {
        case launch(config: LaunchConfig)
        case start(pid: PID)
        case resume(pid: PID)
        case stop(pid: PID)
        
        var arg: IInstrumentArgs {
            switch self {
                case .launch(let config):
                    let selector = "launchSuspendedProcessWithDevicePath:bundleIdentifier:environment:arguments:options:"
                    let arg = DTXArguments()
                    arg.append(config.devicePath)
                    arg.append(config.bundle)
                    arg.append(config.environment)
                    arg.append(config.args)
                    arg.append(config.options)
                    return IInstrumentArgs(selector, dtxArg: arg)
                    
                case .start(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs("startObservingPid:", dtxArg: arg)
                    
                case .resume(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs("resumePid:", dtxArg: arg)
                    
                case .stop(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs("stopObservingPid:", dtxArg: arg)
            }
        }
    }
}
