//
//  IInstruments.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/24.
//

import Cocoa
import LibMobileDevice

class IInstruments: NSObject {
    // MARK: - Private
    private lazy var dtxService: DTXMessageHandle = {
        let server = DTXMessageHandle()
        server.delegate = self
        return server
    }()
    
    private lazy var sendQ: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var receiveQ: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
        
    // MARK: - Public Getter
    public private(set) var isConnected = false
}

extension IInstruments {
    public var fd: Int32? {
        if let fd = dtxService.fd() as? Int32 {
            return fd
        }
        return nil
    }
    
    public func stop() {
        isConnected = false
        dtxService.stopService()
    }
    
    /// 启动instruments服务通道 socket
    /// - Parameter device: deivce
    /// - Returns: success
    @discardableResult
    public func start(_ device: IDevice) -> Bool {
        guard let device_t = device.device_t else {
            return false
        }
        
        isConnected = dtxService.connectInstrumentsService(withDevice: device_t)
        return isConnected
    }
    
    /// 设置服务建立频道 channel
    /// - Parameter service: 对应的服务 IInstrumentsServiceName
    public func setup(service: any IInstrumentsServiceProtocol) {
        if !isConnected {
            return
        }
        
        if !dtxService.isVaildServer(service.server.rawValue) {
            return
        }
        
        let arg = DTXArguments()
        arg.appendUInt32Num(service.server.channel)
        arg.append(service.server.rawValue)
        
        dtxService.send(withChannel: 0,
                        identifier: service.server.channel,
                        selector: "_requestChannelWithCode:identifier:",
                        args: arg,
                        expectsReply: true)
    }
    
    /// 对socket通道发送请求
    /// - Parameters:
    ///   - channel: 对应的服务id
    ///   - identifier: 发送消息的id
    ///   - selector: 对应服务响应的selector 例：响应"com.apple.instruments.server.services.deviceinfo" 对应的 "runningProcesses"
    ///   - dtxArg: 响应服务所需的参数
    ///   - expectsReply: expectsReply
    public func send(channel: UInt32,
                     identifier: UInt32,
                     selector: String,
                     dtxArg: DTXArguments?,
                     expectsReply: Bool) {
        sendQ.addOperation { [weak self] in
            self?.dtxService.send(withChannel: channel,
                                  identifier: identifier,
                                  selector: selector,
                                  args: dtxArg,
                                  expectsReply: expectsReply)
        }
    }
    
    /// 从建立的instruments socket通道取数据
    /// - Parameter complete: 完成的回调
    public func receive(_ complete: ((DTXReceiveObject?) -> Void)? = nil) {
        receiveQ.addOperation { [weak self] in
            let result = self?.dtxService.receive()
            complete?(result)
        }
    }
}


extension IInstruments: DTXMessageHandleDelegate {
    func progress(_ progress: DTXMessageProgressState, message: String?, handle: DTXMessageHandle) {
        debugPrint("[progress] - \(progress) - \(message ?? "none message")")
    }
    
    func error(_ error: DTXMessageErrorCode, message: String?, handle: DTXMessageHandle) {
        if error == .payLoadParseFailed, let msg = message {
            print("[Error] - \(msg)")
        }
    }
}
