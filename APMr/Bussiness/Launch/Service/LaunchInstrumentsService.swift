//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    private var monitorPid: UInt32? = nil
    
    private lazy var parser = Parser()
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let process = IInstrumentsProcesscontrol()
        process.delegate = self
        
        let core = IInstrumentsCoreProfileSessionTap()
        core.delegate = self

        let group = IInstrumentsServiceGroup()
        group.config([process, core])
        return group
    }()
}

extension LaunchInstrumentsService {
    func launch(app: IApp) {
        if let client: IInstrumentsCoreProfileSessionTap = serviceGroup.client(.coreprofilesessiontap) {
            client.setConfig()
            client.start()
        }
        
        if let client: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) {
            var config = IInstrumentsProcesscontrol.LaunchConfig.common(bundle: app.bundleId)
            config.environment = ["OS_ACTIVITY_DT_MODE": true,
                                  "HIPreventRefEncoding": true,
                                  "DYLD_PRINT_TO_STDERR": true]
            client.launch(config: config)
        }
    }
}

extension LaunchInstrumentsService {
    public func stopService() {
        serviceGroup.stop()
    }
    
    public func start(_ device: DeviceItem,
                      _ complete: @escaping (Bool, LaunchInstrumentsService) -> Void) {
        DispatchQueue.global().async {
            var success = false
            if let iDevice = IDevice(device) {
                success = self.serviceGroup.start(iDevice)
            }
            complete(success, self)
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func launch(pid: UInt32) {
        parser.tracePid = pid
        monitorPid = pid
    }
}

extension LaunchInstrumentsService: IInstrumentsCoreProfileSessionTapDelegate {
    func launch(data: Data) {
        parser.parse(data: data)
    }
}

