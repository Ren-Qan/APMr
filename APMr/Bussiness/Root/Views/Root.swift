//
//  Root.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct Root: View {
    @StateObject private var service = Service()
    
    @StateObject private var deviceService = DeviceService()
    
    @StateObject private var performanceService = PerformanceInstrumentsService()
        
    @StateObject private var launchService = LaunchInstrumentsService()
        
    var body: some View {
        NavigationSplitView {
            List(selection: $service.selection) {
                Section("功能") {
                    ForEach(Service.siders) { sider in
                        NavigationLink(sider.title, value: sider)
                    }
                }
            }
        } detail: {
            switch service.selection.state {
                case .performance:
                    PerformanceView()
                        .environmentObject(deviceService)
                        .environmentObject(performanceService)
                        .padding(.all, 5)
                    
                case .launch:
                    LaunchView()
                        .environmentObject(deviceService)
                        .environmentObject(launchService)
                        .padding(.all, 5)
                    
                default:
                    Text(service.selection.title + " In Progress")
            }
        }
        .navigationTitle(
            Text(verbatim: performanceService.isMonitoringPerformance ? "Pid: \(performanceService.monitorPid)" : "")
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu {
                    ForEach(deviceService.deviceList) { device in
                        Button {
                            if let beforeDevice = deviceService.selectDevice, beforeDevice.id == device.id {
                                return
                            }
                            deviceService.selectDevice = device
                            deviceService.selectApp = nil
                            deviceService.userApplist = []
                            deviceService.refreshApplist(device)
                        } label: {
                            Label(device.deviceName,
                                  systemImage: device.type == .usb ? "cable.connector.horizontal" : "wifi")
                            .labelStyle(.titleAndIcon)
                        }
                    }
                } label: {
                    if let device = deviceService.selectDevice {
                        Text("\(device.deviceName)")
                        Image(systemName: device.type == .usb ? "cable.connector.horizontal" : "wifi")
                    } else {
                        Text(deviceService.deviceList.count <= 0 ? "暂无检测到设备" : "请选择设备")
                    }
                }
                .disabled(deviceService.deviceList.count <= 0)
                .disabled(performanceService.isMonitoringPerformance)
                .frame(minWidth: 100)
                .labelStyle(TitleAndIconLabelStyle.titleAndIcon)
            }
            
            ToolbarItem(placement: .navigation) {
                Menu {
                    if let app = deviceService.lastSelectApp {
                        Section("Last") {
                            Button(app.name) {
                                deviceService.selectApp = app
                            }
                        }
                    }
                    
                    Section("App") {
                        ForEach(deviceService.userApplist) { app in
                            Button(app.name) {
                                deviceService.selectApp = app
                            }
                        }
                    }
                } label: {
                    Text(deviceService.selectApp?.name ?? "请选择App")
                }
                .disabled(deviceService.userApplist.count <= 0)
                .disabled(performanceService.isMonitoringPerformance)
                .frame(minWidth: 100)
            }
        }
        .onAppear {
            deviceService.injectClosure = { device in
                guard let selectDevice = deviceService.selectDevice else {
                    return
                }
                
                let item = deviceService.deviceList.first { item in
                    return item.deviceName == selectDevice.deviceName && item.id == selectDevice.id
                }
                
                if item == nil {
                    deviceService.reset()
                    launchService.stop()
                    performanceService.stopService()
                }
                
            }
            deviceService.refreshDeviceList()
        }
    }
}
