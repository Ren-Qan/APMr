//
//  IInstproxy.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

class IInstproxy: ILockdownProtocol {
    private var service_t: lockdownd_service_descriptor_t? = nil
    private var client_t: instproxy_client_t? = nil
    
    required convenience init?(_ device: IDevice, _ lockdown: ILockdown) {
        self.init()
        guard let service_t = lockdown.service_t(INSTPROXY_SERVICE_NAME),
              let device_t = device.device_t else {
            return nil
        }
        
        self.service_t = service_t
        let state = instproxy_client_new(device_t, service_t, &client_t)
        
        if (state.rawValue != 0) {
            return nil
        }
    }
    
    deinit {
        if let service_t = service_t {
            lockdownd_service_descriptor_free(service_t)
        }
        
        if let client_t = client_t {
            instproxy_client_free(client_t)
        }
    }
}

extension IInstproxy {
    public var applist: [IApp] {
        guard let client_t = client_t else {
            return []
        }
        
        var result: plist_t? = nil
        let filter = plist_new_dict()
        let key = plist_new_string("Any")
        plist_dict_set_item(filter, "ApplicationType", key)
        
        instproxy_browse(client_t, filter, &result)
        var resultArr: [IApp] = []
        
        if let result = result,
           let arr = plist_to_nsobject(result) as? [[String : Any]] {
            let objects = Mapper<IApp>().mapArray(JSONObject: arr) ?? []
            resultArr = objects
        }
        
        if let result = result {
            plist_free(result)
        }
        
        if let filter = filter {
            plist_free(filter)
        }
        
        return resultArr
    }
}
