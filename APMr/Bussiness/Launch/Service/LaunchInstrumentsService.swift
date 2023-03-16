//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    private var monitorPid: UInt32? = nil

    private var readSource: DispatchSourceRead?
    
    private lazy var parser = Parser()
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let device = IInstrumentsDeviceInfo()
        device.delegate = self
        
        let process = IInstrumentsProcesscontrol()
        process.delegate = self
        
        let core = IInstrumentsCoreProfileSessionTap()
        core.delegate = self

        let group = IInstrumentsServiceGroup()
        group.config([device, process, core])
        return group
    }()
    
    // MARK: - TEST CODE -
    var block: (() -> Void)? = nil
    var killName: String = ""
}

extension LaunchInstrumentsService {
    func core(app: IInstproxyAppInfo) {
        killName = app.executableName
        
        block = { [weak self] in
            if let client: IInstrumentsProcesscontrol = self?.serviceGroup.client(.processcontrol) {
                client.launch(config: .common(bundle: app.bundleId))
            }
        }
        
        if let client: IInstrumentsDeviceInfo = serviceGroup.client(.deviceinfo) {
            client.machTime()
            client.traceCodes()
        }
    }
}

extension LaunchInstrumentsService {
    public func stopService() {
        serviceGroup.stop()
        readSource?.cancel()
        readSource = nil
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
        self.monitorPid = pid
    }
}

extension LaunchInstrumentsService: IInstrumentsDeviceInfoDelegate {
    func running(process: [[String : Any]]) {

    }
    
    func trace(codes: [Int64 : String]) {
        parser.traceCodes = codes
        
        self.block?()
        self.block = nil
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            if let client: IInstrumentsCoreProfileSessionTap = self.serviceGroup.client(.coreprofilesessiontap) {
                client.setConfig()
                client.start()
            }
        }
    }
    
    func machTime(info: [Any]) {
        parser.machInfo = info
        parser.usecs_since_epoch = Date().timeIntervalSince1970 * 1000000
    }
}

extension LaunchInstrumentsService: IInstrumentsCoreProfileSessionTapDelegate {
    func launch(data: Data) {
        parser.parse(data: data)
    }
}

