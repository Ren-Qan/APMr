//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import Foundation
import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    private var monitorPid: UInt32? = nil
    
    private lazy var parser = CoreParser()
    
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
    
    private var app: IApp? = nil
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
    
    public func launch(app: IApp) {
        self.app = app
//        if let client: IInstruments.Processcontrol = self.serviceGroup.client(.processcontrol) {
//            var config = IInstruments.Processcontrol.LaunchConfig.common(bundle: app.bundleId)
//            config.environment = ["OS_ACTIVITY_DT_MODE": true,
//                                  "HIPreventRefEncoding": true,
//                                  "DYLD_PRINT_TO_STDERR": true]
//            client.launch(config: config)
//        }
        if let client: IInstruments.DeviceInfo = serviceGroup.client(.deviceinfo) {
            client.traceCodes()
            client.machTime()
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func launch(pid: UInt32) {
        parser.tracePid = pid
        monitorPid = pid
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日-HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        
        let date = Date()
        print("[PID:\(pid)] \(formatter.string(from: date))")
        
    }
}

extension LaunchInstrumentsService: IInstrumentsCoreProfileSessionTapDelegate {
    func parserV1(_ model: IInstruments.CoreProfileSessionTap.ModelV1) {
        guard let app = self.app else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日-HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        
        let date = Date()
        print("[RUN] \(formatter.string(from: date))")
        
        if let client: IInstruments.Processcontrol = self.serviceGroup.client(.processcontrol) {
            var config = IInstruments.Processcontrol.LaunchConfig.common(bundle: app.bundleId)
            config.environment = ["OS_ACTIVITY_DT_MODE": true,
                                  "HIPreventRefEncoding": true,
                                  "DYLD_PRINT_TO_STDERR": true]
            client.launch(config: config)
        }
    }
    
    func parserV2(_ model: IInstruments.CoreProfileSessionTap.ModelV2) {
        parser.merge(model.threadMap)
        model.elements.forEach { element in
            parser.feed(element)
        }
    }
    
    func parserV3(_ model: IInstruments.CoreProfileSessionTap.ModelV3) {
        
    }
    
    func parserV4(_ model: IInstruments.CoreProfileSessionTap.ModelV4) {
        model.elements.forEach { element in
            parser.feed(element)
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsDeviceInfoDelegate {
    func trace(codes: [Int64 : String]) {
        parser.traceCodes = codes
    }
    
    func machTime(info: IInstruments.DeviceInfo.MT) {
        
        
        parser.traceMachTime = info
                
        if let client: IInstruments.CoreProfileSessionTap = self.serviceGroup.client(.coreprofilesessiontap) {
            client.setConfig()
            client.start()
        }
    
    }
}
