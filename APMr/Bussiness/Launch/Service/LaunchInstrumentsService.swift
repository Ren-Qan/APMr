//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import Foundation
import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    private var monitorPid: PID? = nil
    private var app: IApp? = nil
    
    private var traceCodes: [Int64 : String]? = nil
    private var machTime: IInstruments.DeviceInfo.MT? = nil
        
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
    public func stop() {
        if let client: IInstruments.CoreProfileSessionTap = serviceGroup.client(.coreprofilesessiontap) {
            client.clear()
        }
        
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
    
    public func prepare(_ app: IApp) {
        self.app = app
        
        if let client: IInstruments.DeviceInfo = serviceGroup.client(.deviceinfo) {
            client.runningProcess()
        }
        
        if let client: IInstruments.CoreProfileSessionTap = serviceGroup.client(.coreprofilesessiontap) {
            client.clear()
        }
    }
    
    public func launch(app: IApp) {
        self.app = app
        if let client: IInstruments.DeviceInfo = self.serviceGroup.client(.deviceinfo) {
            client.traceCodes()
            client.machTime()
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func launch(pid: PID) {
        monitorPid = pid
    }
}

extension LaunchInstrumentsService: IInstrumentsCoreProfileSessionTapDelegate {    
    
}

extension LaunchInstrumentsService: CoreLiveProtocol {
    var traceCodesMap: [TraceID : String]? {
        return traceCodes
    }
    
    var traceMachTime: IInstruments.DeviceInfo.MT? {
        return machTime
    }
}

extension LaunchInstrumentsService: IInstrumentsDeviceInfoDelegate {
    func running(process: [IInstruments.DeviceInfo.Process]) {
        guard let app = self.app else {
            return
        }
        
        if let process = process.first(where: { p in  p.bundleId == app.bundleId }) {
            if let client: IInstruments.Processcontrol = serviceGroup.client(.processcontrol) {
                client.kill(pid: process.pid)
            }
        }
    }
    
    func trace(codes: [TraceID : String]) {
        traceCodes = codes
    }
    
    func machTime(info: IInstruments.DeviceInfo.MT) {
        self.machTime = info
        if let client: IInstruments.CoreProfileSessionTap = self.serviceGroup.client(.coreprofilesessiontap) {
            client.setConfig()
            client.start()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日-HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        
        guard let app = self.app else {
            return
        }
        
        print("[BASE] \(formatter.string(from: Date(timeIntervalSince1970: info.usecs_since_epoch / 1000000)))")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
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
    }
}


//extension LaunchInstrumentsService: CoreLiveCallStacksDelegate {
//    func callStack(_ result: CoreParser.Handle.CallStack.CS) {
//        print("\n[\(result.timestamp)] --- \(result.tpMap?.process ?? String(format: "0x%X", result.tid))")
//        var padding = " "
//        result.frames.forEach { cs in
//
//            if let uuid = cs.uuid {
//                let string = padding + String(format: "\(uuid) - 0x%X", cs.frame)
//                print(string)
//            } else {
//                let string = padding + String(format: "0x%X", cs.frame)
//                print(string)
//            }
//
//            padding += " "
//        }
//    }
//}
//
//extension LaunchInstrumentsService: CoreStackShotDelegate {
//
//}
