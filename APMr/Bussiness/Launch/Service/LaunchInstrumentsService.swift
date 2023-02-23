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
    
    // MARK: - Test
    private var codes: [Int64 : String] = [:]
    private var machInfo: [Any] = []
    private var usecs_since_epoch: TimeInterval = 0
}

extension LaunchInstrumentsService {
    func test() {
        if let client: IInstrumentsDeviceInfo = serviceGroup.client(.deviceinfo) {
            client.machTime()
            client.traceCodes()
        }
    }
    
    func core(app: IInstproxyAppInfo) {
        if let client: IInstrumentsCoreProfileSessionTap = serviceGroup.client(.coreprofilesessiontap) {
            client.setConfig()
            client.start()
            
            launch(app: app)
        }
    }
    
    func launch(app: IInstproxyAppInfo) {
        if let client: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) {
            var config = IInstrumentsProcesscontrol.LaunchConfig.common(bundle: app.bundleId)
            config.arguments = [
                "OS_ACTIVITY_DT_MODE": true,
                "HIPreventRefEncoding": true,
                "DYLD_PRINT_TO_STDERR": true,
            ]
            client.launch(config: config)
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
    func trace(codes: [Int64 : String]) {
        self.codes = codes
    }
    
    func machTime(info: [Any]) {
        self.machInfo = info
        usecs_since_epoch = Date().timeIntervalSince1970 * 100000
    }
}

extension LaunchInstrumentsService: IInstrumentsCoreProfileSessionTapDelegate {
    
}

