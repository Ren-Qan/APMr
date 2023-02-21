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
    
    private var readSource: DispatchSourceRead?
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        
        let process = IInstrumentsProcesscontrol()
        process.delegate = self
        
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
        readSource?.cancel()
        readSource = nil
    }
}

extension LaunchInstrumentsService {
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
    
    public func setupReadSource(fd: Int32) {
        self.readSource = DispatchSource.makeReadSource(fileDescriptor: fd, queue: .global())
        self.readSource?.setEventHandler { [weak self] in
            self?.serviceGroup.receive()
        }
        self.readSource?.resume()
    }
}

extension LaunchInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {
        if response == nil {
            receiceSeriesNilCount += 1
        } else {
            receiceSeriesNilCount = 0
        }
    }
}

extension LaunchInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func launch(pid: UInt32, arg: IInstrumentRequestArgsProtocol) {
        self.pid = pid
        print("=========\(pid)")
        
        if let client: TESTClinet = serviceGroup.client(.sysmontap) {
            client.pid = pid
            let config: [String : Any] = [
                "bm": 0,
                "ur": 1000,
//                "cpuUsage": true,
                "sampleInterval": 1000000000,
//                "procAttrs": IInstrumentsSysmontap.procAttrs,
//                "sysAttrs": IInstrumentsSysmontap.sysAttrs,
//                "coalAttrs" : IInstrumentsSysmontap.coalAttrs
            ]

            let args = DTXArguments()
            args.append(config)
            client.send(IInstrumentArgs(padding: 2, selector: "setConfig:", dtxArg: args))
            client.send(IInstrumentArgs(padding: 1, selector: "start"))
        }
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
        .sysmontap
    }
    
    func response(_ response: DTXReceiveObject) {

    }
}
