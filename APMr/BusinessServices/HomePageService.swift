//
//  HomePageService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import Cocoa

enum HomePageCharType {
    case cpu
    case gpu
}

class HomePageService: NSObject {
    private lazy var instruments = IInstruments()
    
    private lazy var sysmotap = IInstrumentsSysmontap()
    
    private lazy var deviceInfo = IInstrumentsDeviceInfo()
    
    private lazy var opengl = IInstrumentsOpengl()
    
    private var timer: Timer? = nil
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

private extension HomePageService {
    var instrumentsServices: [any IInstrumentsServiceProtocol] {
        return [sysmotap, deviceInfo, opengl]
    }
}

extension HomePageService {
    func start(_ device: IDevice) -> Bool {
        if instruments.start(device) {
            instrumentsServices.forEach { service in
                service.start(instruments)
            }
            
            sysmotap.register(.setConfig)
            sysmotap.register(.start)
            
            opengl.register(.startSampling)
            return true
        }
        return false
    }
    
    func autoRequestChart() {
        stopRequest()
        timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.sysmotap.request()
            self?.opengl.request()
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopRequest() {
        timer?.invalidate()
        timer = nil
    }
}
