//
//  IInstproxy.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

class IInstproxy: NSObject {
    private var service_t: lockdownd_service_descriptor_t? = nil
    private var instproxy_t: instproxy_client_t? = nil
    
    convenience init?(_ device: IDevice, _ lockdown: ILockdown) {
        self.init()
        guard let service_t = lockdown.service_t(INSTPROXY_SERVICE_NAME),
              let device_t = device.device_t else {
            return nil
        }
        
        self.service_t = service_t
        let state = instproxy_client_new(device_t, service_t, &instproxy_t)
        
        if (state.rawValue != 0) {
            return nil
        }
    }
    
    deinit {
        if let service_t = service_t {
            lockdownd_service_descriptor_free(service_t)
        }
        
        if let instproxy_t = instproxy_t {
            instproxy_client_free(instproxy_t)
        }
    }
}

extension IInstproxy {
    public var applist: [IInstproxyAppInfo] {
        guard let client_t = instproxy_t else {
            return []
        }
        
        var result: plist_t? = nil
        let filter = plist_new_dict()
        plist_dict_set_item(filter, "ApplicationType", plist_new_string("Any"))
        
        let state = instproxy_browse(client_t, filter, &result)
        
        guard state.rawValue == 0,
              let result = result else {
            return []
        }
        
        if let arr = plist_to_nsobject(result) as? [[String : Any]] {
            let objects = Mapper<IInstproxyAppInfo>().mapArray(JSONObject: arr) ?? []
            return objects
        }
        return []
    }
}
