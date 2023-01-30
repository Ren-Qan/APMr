//
//  IDiagnosticsRelay.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/30.
//

import Cocoa
import LibMobileDevice
import SwiftyJSON

class IDiagnosticsRelay: NSObject {
    private var service_t: lockdownd_service_descriptor_t? = nil
    private var client_t: diagnostics_relay_client_t? = nil
    
    convenience init?(_ device: IDevice, _ lockdown: ILockdown) {
        self.init()

        guard let service_t = lockdown.service_t(DIAGNOSTICS_RELAY_SERVICE_NAME),
              let device_t = device.device_t else {
            return nil
        }
        
        self.service_t = service_t
        let state = diagnostics_relay_client_new(device_t, service_t, &client_t)
        
        if (state.rawValue != 0) {
            return nil
        }
    }
}

extension IDiagnosticsRelay {
    public var analysis: [String : Any]? {
        guard let client_t = client_t else {
            return nil
        }
        
        var result: plist_t? = nil
        let state = diagnostics_relay_query_ioregistry_entry(client_t, "AppleSmartBattery", "", &result)
        
        
        if let result = result,
           let dic = plist_to_nsobject(result) as? [String : Any] {
            return dic["IORegistry"] as? [String : Any]
        }
        return nil
    }
}
