//
//  HomepageService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import Cocoa
import Combine

class HomepageService: NSObject, ObservableObject {
    lazy var device: HomepageDeviceService = {
        let device = HomepageDeviceService()
        device.root = self
        return device
    }()
    
    lazy var insturment: HomepageInstrumentsService = {
        let instrument = HomepageInstrumentsService()
        instrument.root = self
        return instrument
    }()
}
