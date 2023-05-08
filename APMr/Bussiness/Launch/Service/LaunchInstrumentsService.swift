//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import QuartzCore
import Cocoa
import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    private var monitorPid: UInt32? = nil
    
    private lazy var parser = Parser()
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let device = IInstruments.DeviceInfo()
        device.delegate = self
        
        let process = IInstruments.Processcontrol()
        process.delegate = self
        
        let core = IInstruments.CoreProfileSessionTap()
        core.delegate = self

        let group = IInstrumentsServiceGroup()
        group.config([process, core, device])
        return group
    }()
}

extension LaunchInstrumentsService {
    func launch(app: IApp) {
        if let client: IInstruments.DeviceInfo = serviceGroup.client(.deviceinfo) {
            client.traceCodes()
            client.machTime()
        }
        
        if let client: IInstruments.CoreProfileSessionTap = serviceGroup.client(.coreprofilesessiontap) {
            client.setConfig()
            client.start()
        }
        
        if let client: IInstruments.Processcontrol = serviceGroup.client(.processcontrol) {
            var config = IInstruments.Processcontrol.LaunchConfig.common(bundle: app.bundleId)
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
        if let client: IInstruments.CoreProfileSessionTap = self.serviceGroup.client(.coreprofilesessiontap) {
            client.stop()
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsCoreProfileSessionTapDelegate {
    func praserV1(_ model: IInstruments.CoreProfileSessionTap.ModelV1) {
        
    }
    
    func praserV2(_ model: IInstruments.CoreProfileSessionTap.ModelV2) {
        
    }
    
    func praserV4(_ model: IInstruments.CoreProfileSessionTap.ModelV4) {
        
    }
}

extension LaunchInstrumentsService: IInstrumentsDeviceInfoDelegate {
    func trace(codes: [Int64 : String]) {
        
    }
    
    func machTime(info: IInstruments.DeviceInfo.MT) {
        
    }
    
    func running(process: [[String : Any]]) {
        
    }
}
