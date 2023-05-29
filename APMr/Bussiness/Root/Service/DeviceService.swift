//
//  DeviceService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import SwiftUI

class DeviceService: ObservableObject {
    @Published var deviceList: [DeviceItem] = []
    @Published var userApplist: [IApp] = []
    @Published var systemApplist: [IApp] = []
    
    @Published var lastSelectDevice: DeviceItem? = nil
    @Published var lastSelectApp: IApp? = nil
    
    @Published var monitorPid: PID? = nil
    @Published var selectDevice: DeviceItem? = nil {
        didSet {
            if let name = selectDevice?.id {
                lastDeviceId = name
            }
        }
    }
    @Published var selectApp: IApp? = nil {
        didSet {
            if let bundleId = selectApp?.bundleId {
                lastBundleId = bundleId
            }
        }
    }
    
    @AppStorage("Last_Select_Bundle_id") private var lastBundleId: String = ""
    @AppStorage("Last_Select_Device_id") private var lastDeviceId: String = ""
    
    var injectClosure: ((DeviceService) -> Void)? = nil
    
    init() {
        NotificationCenter
            .default
            .addObserver(forName: MobileManager.subscribeChangedNotification,
                         object: nil,
                         queue: nil) { _ in
                self.refreshDeviceList()
            }
    }
}

extension DeviceService {
    func reset() {
        selectDevice = nil
        selectApp = nil
        monitorPid = nil
    }
}

extension DeviceService {
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
                
                if item.id == self.lastBundleId {
                    self.lastSelectDevice = result
                }
                
                return result
            }
            
            self.injectClosure?(self)
        }
    }
    
    func refreshApplist(_ device: DeviceItem) {
        DispatchQueue.global().async {
            if let iDevice = IDevice(device),
               let lockdown = ILockdown(iDevice),
               let instproxy = IInstproxy(iDevice, lockdown) {
                let applist = instproxy.applist
                
                var user = [IApp]()
                var system = [IApp]()
                
                applist.forEach { app in
                    if app.applicationType == .user {
                        user.append(app)
                    } else if app.applicationType == .system {
                        system.append(app)
                    }
                    
                    if self.lastBundleId == app.bundleId {
                        self.lastSelectApp = app
                    }
                }
                
                self.userApplist = user
                self.systemApplist = system
            }
        }
    }
}
