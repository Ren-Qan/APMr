//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//


import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    
    private var timer: Timer?
    private var receiceSeriesNilCount = 0
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        
        let process = IInstrumentsProcesscontrol()
        process.delegate = self
        
        let samp = IInstrumentSampling()
//        samp.delegate = self
        let test = TESTClinet()
        
        group.config([process, samp, test])
        return group
    }()
    
    // MARK: - TEST
    var path = ""
    var bundle = ""
    var pid: UInt32 = 0
    var appName = ""
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

extension LaunchInstrumentsService {
    private func stopService() {
        timer?.invalidate()
        timer = nil
        serviceGroup.stop()
    }
}

extension LaunchInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {
        if response == nil {
            receiceSeriesNilCount += 1
        } else {
            receiceSeriesNilCount = 0
        }
        
        let MAX_ERROR_COUNT = 10
        if receiceSeriesNilCount == MAX_ERROR_COUNT {
            stopService()
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func launch(pid: UInt32, arg: IInstrumentRequestArgsProtocol) {
        self.pid = pid
        if let client: IInstrumentSampling = serviceGroup.client(.sampling) {
            
            let dtx = DTXArguments()
            dtx.append(pid)
            client.send(IInstrumentArgs(padding: 5, selector: "setTargetPid:", dtxArg: dtx))
        }
    }
}

extension LaunchInstrumentsService: IInstrumentSamplingDelegate {
    
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
        
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.serviceGroup.receive()
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
        appName = app.name
        
//        if let client: IInstrumentsAppLifeCycle = serviceGroup.client(.applifecycle) {
//            client.start()
//        }
        
//        if let client: IInstrumentSampling = serviceGroup.client(.sampling) {
//            let arg = DTXArguments()
//            arg.append(1)
//            client.send(IInstrumentArgs(padding: 10, selector: "setOutputRate:", dtxArg: arg))
//            client.start()
//        }
  
        if let client: TESTClinet = serviceGroup.client(.applifecycle) {
            client.send(IInstrumentArgs(padding: 1, selector: "recordWithBundleIdentifier:"))
        }
        
//        if let client: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) {
//            client.launch(bundle: bundle)
//        }
    }
    
    public func close() {
        if let client: IInstrumentSampling = serviceGroup.client(.sampling) {
            client.stop()
//            client.samples()
        }
    }
}

class TESTClinet: IInstrumentsBase, IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .applifecycle
    }
    
    func response(_ response: DTXReceiveObject) {
        print("[Test] [Arr] ---- \(response.array)")
        print("[Test] [obj] ---- \(response.object)")
    }
    
    
}
