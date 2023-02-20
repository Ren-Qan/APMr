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
//        process.delegate = self

        let sys = TESTClinet()
        
        group.config([process, sys])
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
    func stopService() {
        timer?.invalidate()
        timer = nil
        serviceGroup.stop()
    }
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
        
//        DispatchQueue.global().async {
//            while(true) {
//                self.serviceGroup.receive()
//            }
//        }
        
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.serviceGroup.receive()
        }
        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
        self.timer = timer
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
        print("=========\(pid)")
    }
}

extension LaunchInstrumentsService: IInstrumentSamplingDelegate {
    
}

extension LaunchInstrumentsService {
    public func test(app: IInstproxyAppInfo, service: String) {
        bundle = app.bundleId
        path = app.path
        appName = app.name
        
        if let client: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) {
            client.launch(bundle: bundle)
        }
    
        if let client: TESTClinet = serviceGroup.client(.applifecycle) {
            let arg = DTXArguments()
            arg.append(path)
            client.send(IInstrumentArgs(padding: 3, selector: service, dtxArg: arg))
//            client.send(IInstrumentArgs(padding: 2, selector: "startSampling"))
        }
        
    }
    
    public func close() {
//        if let client: TESTClinet = serviceGroup.client(.sampling) {
//            client.send(IInstrumentArgs(padding: 1, selector: "stopSampling"))
//        }
    }
}

class TESTClinet: IInstrumentsBase, IInstrumentsServiceProtocol {
    var pid: UInt32 = 0
    
    var server: IInstrumentsServiceName {
        .applifecycle
    }
    
    func response(_ response: DTXReceiveObject) {
        print(response.array)
        print(response.object)
    }
}
