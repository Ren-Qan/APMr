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
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        
        let device = IInstrumentsDeviceInfo()
        device.delegate = self
        
        let process = IInstrumentsProcesscontrol()
        process.delegate = self
        
        let core = IInstrumentsCoreProfileSessionTap()
        core.delegate = self

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
                var config = IInstrumentsProcesscontrol.LaunchConfig.common(bundle: app.bundleId, killExisting: false)
                config.environment = [
                    "OS_ACTIVITY_DT_MODE": 1,
                    "HIPreventRefEncoding": 1,
                    "DYLD_PRINT_TO_STDERR": 1,
                    "DYLD_PRINT_ENV" : 1,
                    "DYLD_PRINT_APIS" : 1,
                ]
                client.launch(config: config)
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
                if let fd = self.serviceGroup.fd {
                    self.setupReadSource(fd: fd)
                }
            }
            complete(success, self)
        }
    }
    
    private func setupReadSource(fd: Int32) {
        self.readSource = DispatchSource.makeReadSource(fileDescriptor: fd, queue: .global())
        self.readSource?.setEventHandler { [weak self] in
            self?.serviceGroup.receive()
        }
        self.readSource?.resume()
    }
}

extension LaunchInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {

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

        DispatchQueue.global().asyncAfter(deadline: .now() + 4) {
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

