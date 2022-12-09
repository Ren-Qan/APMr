//
//  HomepageDeviceService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import Combine

class HomepageDeviceService: NSObject {
    public weak var root: HomepageService? = nil
    
    public var deviceList: [DeviceItem] = [] {
        didSet {
            root?.objectWillChange.send()
        }
    }
    
    public var selectDevice: DeviceItem? = nil {
        didSet {
            root?.objectWillChange.send()
        }
    }

    public var appList: [IInstproxyAppInfo] = [] {
        didSet {
            root?.objectWillChange.send()
        }
    }
    
    public var selectApp: IInstproxyAppInfo? = nil {
        didSet {
            root?.objectWillChange.send()
        }
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: MobileManager.subscribeChangedNotification, object: nil, queue: nil) { _ in
            self.refreshDeviceList()
        }
    }
}

extension HomepageDeviceService {
    func refreshDeviceList() {
        DispatchQueue.global().async {
            MobileManager.share.refreshDeviceList()
            
            var nameMap: [String : String] = [:]
            
            self.deviceList = MobileManager.share.deviceList.compactMap { item in
                var result = item
                
                if let name = nameMap[result.udid] {
                    result.deviceName = name
                } else {
                    if let iDevice = IDevice(item),
                       let lockdown = ILockdown(iDevice),
                       let name = lockdown.fetchDeviceInfo?.deivceName {
                        result.deviceName = name
                        nameMap[result.udid] = name
                    }
                }
                return result
            }
        }
    }
    
    func refreshApplist() {
        DispatchQueue.global().async {
            guard let device = self.selectDevice else {
                return
            }
            
            if let iDevice = IDevice(device),
               let lockdown = ILockdown(iDevice),
               let instproxy = IInstproxy(iDevice, lockdown) {
                self.appList = instproxy.applist
            }
        }
    }
}
