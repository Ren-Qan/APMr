//
//  IDevice.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/24.
//

import Cocoa
import LibMobileDevice

class IDevice {
    public private(set) var device_t: idevice_t? = nil
    public private(set) var phone: P? = nil
        
    convenience init?(_ phone: IDevice.P) {
        var _device: idevice_t? = nil
        idevice_new_with_options(&_device, phone.udid, phone.type.option)
        
        if let _device = _device {
            self.init()
            self.device_t = _device
            self.phone = phone
        } else {
            return nil
        }
    }
    
    deinit {
        if let device = device_t {
            idevice_free(device)
        }
    }
}

// MARK: - Public 
extension IDevice {
    func reset(_ phone: IDevice.P) {
        if let device = self.device_t {
            idevice_free(device)
        }
        
        self.phone = nil
        self.device_t = nil
        
        var _device: idevice_t? = nil
        idevice_new_with_options(&_device, phone.udid, phone.type.option)
        
        if let _device = _device {
            self.device_t = _device
            self.phone = phone
        }
    }
}

extension IDevice {
    enum C {
        case usb
        case net
        
        var option: idevice_options {
            switch self {
                case .usb:
                    return IDEVICE_LOOKUP_USBMUX
                case .net:
                    return IDEVICE_LOOKUP_NETWORK
            }
        }
    }
    
    struct P: Identifiable {
        var id: String { udid + "\(type)" }
        let udid: String
        let type: C
        var name: String = ""
        var osVersion: String = ""
        
        init(udid: String, type: C) {
            self.udid = udid
            self.type = type
        }
    }
}
