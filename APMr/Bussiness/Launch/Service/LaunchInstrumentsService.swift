//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//


import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    
    private var timer: Timer?
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        
        let process = IInstrumentsProcessControlByDictionary()
        process.delegate = self
        
        let objc = IInstrumentsObjectAlloc()
        objc.delegate = self
        
        let device = IInstrumentsDeviceInfo()
        device.delegate = self
        
        group.config([process, objc, device])
        return group
    }()
    
    // MARK: - TEST
    var path = ""
    var bundle = ""
    var pid: UInt32 = 0
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

extension LaunchInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {
        
    }
}

extension LaunchInstrumentsService: IInstrumentsProcessControlByDictionaryDelegate {
    func launch(pid: UInt32, arg: IInstrumentRequestArgsProtocol) {
        self.pid = pid
        
//        if let client: IInstrumentsProcessControlByDictionary = serviceGroup.client(.pcbd) {
//            client.start(pid: pid)

//            client.resume(pid: pid)
//        }
    }
}

extension LaunchInstrumentsService: IInstrumentsObjectAllocDelegate {
    func prepared(response: [String : Any], arg: IInstrumentRequestArgsProtocol) {
        if let client: IInstrumentsProcessControlByDictionary = serviceGroup.client(.pcbd) {
            client.launch(config: .common(path: path, bundle: bundle, env: response))
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsDeviceInfoDelegate {
    
}

extension LaunchInstrumentsService {
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
    
    public func autoReceive() {
        timer?.invalidate()
        timer = nil
        
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.serviceGroup.receive()
            
            if let clinet: IInstrumentsObjectAlloc = self?.serviceGroup.client(.objectalloc), let pid = self?.pid, pid > 0 {
                clinet.collection(pid: pid)
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
        self.timer = timer
    }
}

extension LaunchInstrumentsService {
    public func test(app: IInstproxyAppInfo) {
        bundle = app.bundleId
        path = app.path
        
        if let client: IInstrumentsObjectAlloc = serviceGroup.client(.objectalloc) {
            client.parpare()
        }
    }
    
    public func close() {
        if let client: IInstrumentsObjectAlloc = serviceGroup.client(.objectalloc) {
            client.stop()
        }
        
//        if let client: IInstrumentsProcessControlByDictionary = serviceGroup.client(.pcbd) {
//            client.stop(pid: self.pid)
//        }
    }
}
