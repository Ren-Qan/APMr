//
//  ADevice.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import SwiftUI

class ADevice: NSObject, ObservableObject {
    @AppStorage("Last_Select_Bundle_id") private var lastBundleId: String = ""
    @AppStorage("Last_Select_Device_id") private var lastDeviceId: String = ""
    
    @Published var phoneList: [IDevice.P] = []
    @Published var userApplist: [IApp] = []
    @Published var systemApplist: [IApp] = []
    
    @Published var runningProcess: [IInstruments.DeviceInfo.Process] = []
    
    @Published var lastSelectPhone: IDevice.P? = nil
    @Published var lastSelectApp: IApp? = nil
    
    @Published var monitorPid: PID? = nil
    @Published var selectPhone: IDevice.P? = nil {
        didSet {
            if let name = selectPhone?.id {
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
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let device = IInstruments.DeviceInfo()
        device.delegate = self
        
        let group = IInstrumentsServiceGroup()
        group.config([device])
        
        return group
    }()
    
    var injectClosure: ((ADevice) -> Void)? = nil
    
    override init() {
        super.init()
        NotificationCenter
            .default
            .addObserver(forName: MobileManager.subscribeChangedNotification,
                         object: nil,
                         queue: nil) { _ in
                self.refreshDeviceList()
            }
        refreshDeviceList()
    }
}

extension ADevice {
    func reset() {
        selectPhone = nil
        selectApp = nil
        monitorPid = nil
        serviceGroup.stop()
    }
}

extension ADevice: IInstrumentsDeviceInfoDelegate {
    func running(process: [IInstruments.DeviceInfo.Process]) {
        runningProcess = process
        serviceGroup.stop()
    }
}

extension ADevice {
    func refreshDeviceList() {
        DispatchQueue.global().async {
            var nameCache: [String : String] = [:]
            var osCache: [String : String] = [:]
            self.phoneList = MobileManager.share.deviceList.compactMap { item in
                var result = item
                
                if let name = nameCache[result.udid],
                    let version = osCache[result.udid] {
                    result.name = name
                    result.osVersion = version
                } else {
                    if let iDevice = IDevice(item),
                       let lockdown = ILockdown(iDevice),
                       let info = lockdown.fetchDeviceInfo {
                        result.name = info.deivceName
                        result.osVersion = info.osVersion
                        
                        nameCache[result.udid] = info.deivceName
                        osCache[result.udid] = info.osVersion
                    }
                }
                
                if item.id == self.lastBundleId {
                    self.lastSelectPhone = result
                }
                
                return result
            }
            
            self.injectClosure?(self)
        }
    }
    
    func refreshRunningProcess(_ phone: IDevice.P) {
        guard let iDevice = IDevice(phone) else {
            return
        }
        serviceGroup.start(iDevice)
        if let client: IInstruments.DeviceInfo = serviceGroup.client(.deviceinfo) {
            client.runningProcess()
        }
    }
    
    func refreshApplist(_ phone: IDevice.P) {
        DispatchQueue.global().async {
            if let iDevice = IDevice(phone),
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
