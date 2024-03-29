//
//  ILockdown.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

protocol ILockdownProtocol {
    init?(_ device: IDevice, _ lockdown: ILockdown)
}

class ILockdown {
    public private(set) var lockdown_t: lockdownd_client_t? = nil
    
    convenience init?(_ device: IDevice) {
        self.init()
        guard let device_t = device.device_t else {
            return nil
        }

        let state = lockdownd_client_new_with_handshake(device_t, &lockdown_t, "Lockdown")
        
        if state.rawValue != 0 {
            return nil
        }
    }
    
    deinit {
        if let lockdown_t = lockdown_t {
            lockdownd_client_free(lockdown_t)
        }
    }
}

extension ILockdown {
    public func fetchDeviceInfo() -> ILockdownDeivceInfo? {
        guard let lockdown_t = lockdown_t else {
            return nil
        }
        
        var info: ILockdownDeivceInfo? = nil
        var result: plist_t? = nil
        lockdownd_get_value(lockdown_t, nil, nil, &result)
        
        
        if let json = plist_to_nsobject(result) as? [String : Any] {
            info = Mapper<ILockdownDeivceInfo>().map(JSON: json)
        }
         
        if let result = result {
            plist_free(result)
        }
        
        return info
    }
    
    public func service_t(_ name: String) -> lockdownd_service_descriptor_t? {
        guard let lockdown_t = lockdown_t else {
            return nil
        }
        
        var service_t: lockdownd_service_descriptor_t? = nil
        lockdownd_start_service(lockdown_t, name, &service_t)
        return service_t
    }
}
