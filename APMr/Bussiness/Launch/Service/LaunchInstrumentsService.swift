//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//


import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    
    private var client = TESTClinet()
    private var readSource: DispatchSourceRead?
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        
        let process = IInstrumentsProcesscontrol()
        process.delegate = self
                
        group.config([process, client])
        return group
    }()
    
    // MARK: - TEST
    private var path = ""
    private var bundle = ""
    private var appName = ""
    private var pid: UInt32 = 0
    private var selectors = [String]()
}

extension LaunchInstrumentsService {
    func stopService() {
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

    }
}

extension LaunchInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func outputReceived(_ msg: String) {
    }

    func launch(pid: UInt32, arg: IInstrumentRequestArgsProtocol) {
        self.pid = pid
    }
}

extension LaunchInstrumentsService: IInstrumentSamplingDelegate {
    
}



extension LaunchInstrumentsService {
    func send(str: String) {

//        if let path = Bundle.main.path(forResource: "string", ofType: "txt") {
//            do {
//                let text = try String(contentsOfFile: path, encoding: .utf8)
//                let arr = text.components(separatedBy: "\r\n")
//                var selectors = arr.compactMap { item in
//                    return item.components(separatedBy:"\t").last
//                }
//
//                if let client: TESTClinet = serviceGroup.client(.applifecycle) {
//                    client.selectors = selectors
//                    var i: UInt32 = 1
//                    selectors.forEach { selector in
//                        client.send(IInstrumentArgs(padding: i, selector: selector))
//                        i += 1
//                    }
//                }
//            } catch {
//            }
//        }
        
//        if let client: TESTClinet = serviceGroup.client(.applifecycle) {
//            client.send(IInstrumentArgs(padding: 1, selector: str))
//        }
        
//
        let arg = DTXArguments()
        arg.append(10)
        client.send(IInstrumentArgs(padding: 1, selector: "setSamplingRate:", dtxArg: arg))
        client.send(IInstrumentArgs(padding: 2, selector: "startSampling"))
        
        let arg1 = DTXArguments()
        arg1.append(pid)
        client.send(IInstrumentArgs(padding: 10, selector: "setTargetPid:", dtxArg: arg1))
    
        
        client.send(IInstrumentArgs(padding: 11, selector: "taskForPid:", dtxArg: arg1))
        

    }
    
    public func test(app: IInstproxyAppInfo) {
        bundle = app.bundleId
        path = app.path
        appName = app.name
                
        if let client: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) {
            client.launch(bundle: bundle)
        }
    }
    
    public func stop() {
        let arg = DTXArguments()
        arg.append(10)
        
        client.send(IInstrumentArgs(padding: 3, selector: "setOutputRate:", dtxArg: arg))
        client.send(IInstrumentArgs(padding: 4, selector: "stopSampling"))
    }
}

class TESTClinet: IInstrumentsBase, IInstrumentsServiceProtocol {
    var pid: UInt32 = 0
    var selectors = [String]()
    
    var server: IInstrumentsServiceName {
        .applifecycle
    }
    
    func response(_ response: DTXReceiveObject) {
        if let object = response.object {
            let str = "\(object)"
            if str.contains("it does not respond to the selector") || str.contains("the selector is not allowed") {
                return
            }
        }
        
        
        let index = UInt32.max - response.identifier - 1
        if index < selectors.count {
            print("Response --- \(self.selectors[Int(index)])")
        }
        
    
        if let arr = response.array {
            print("[TEST] [Arr] ----- \(arr)")
        }
        
        if let object = response.object {
            print("[TEST] [Obj] ----- \(object)")
            
            if let data = object as? Data {
                let str = String(data: data, encoding: .utf8)
                print("\(String(data: data, encoding: .utf8))")
            }
            
        }
    }
}
