//
//  HomepageDeviceService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa

class HomepageDeviceService: NSObject, ObservableObject {    
    @Published var deviceList: [DeviceItem] = []
    @Published var userApplist: [IInstproxyAppInfo] = []
    @Published var systemApplist: [IInstproxyAppInfo] = []
    
    @Published var selectDevice: DeviceItem? = nil
    @Published var selectApp: IInstproxyAppInfo? = nil
    
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
    
    func refreshApplist(_ device: DeviceItem) {
        DispatchQueue.global().async {
            if let iDevice = IDevice(device),
               let lockdown = ILockdown(iDevice),
               let instproxy = IInstproxy(iDevice, lockdown) {
                let applist = instproxy.applist
                
                var user = [IInstproxyAppInfo]()
                var system = [IInstproxyAppInfo]()
                
                applist.forEach { app in
                    if app.applicationType == .user {
                        user.append(app)
                    } else if app.applicationType == .system {
                        system.append(app)
                    }
                }
                
                self.userApplist = user
                self.systemApplist = system
            }
        }
    }
}
