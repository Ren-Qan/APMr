//
//  HomepageView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct HomepageView: View {
    @StateObject private var service = HomepageService()
    
    @StateObject private var deviceService = HomepageDeviceService()
    
    @StateObject private var instrumentService = HomepageInstrumentsService()
            
    var body: some View {
        NavigationSplitView {
            List(selection: $service.selectionSider) {
                Section("功能") {
                    ForEach(HomepageService.siders) { sider in
                        NavigationLink(sider.title, value: sider)
                    }
                }
            }
        } detail: {
            switch service.selectionSider.state {
            case .performance:
                PerformanceView()
                        .environmentObject(service)
                        .environmentObject(instrumentService)
                        .padding(.all, 5)
                        
            default:
                Text(service.selectionSider.title + " In Progress")
            }
        }
        .navigationTitle(
            Text(verbatim: instrumentService.isMonitoringPerformance ? "Pid: \(instrumentService.monitorPid)" : "")
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu {
                    ForEach(deviceService.deviceList) { device in
                        Button {
                            if let beforeDevice = service.selectDevice, beforeDevice.id == device.id { } else {
                                service.selectDevice = device
                                service.selectApp = nil
                                deviceService.userApplist = []
                                deviceService.refreshApplist(device)
                            }
                        } label: {
                            Label(device.deviceName,
                                  systemImage: device.type == .usb ? "bolt.square" : "wifi.square")
                            .labelStyle(.titleAndIcon)
                        }
                    }
                } label: {
                    if let device = service.selectDevice {
                        Text("device.deviceName")
                        Image(systemName: device.type == .usb ? "cable.connector.horizontal" : "wifi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
//                        Label(device.deviceName,
//                              systemImage: )
//                            .labelStyle(.titleAndIcon)
                    } else {
                        Text(deviceService.deviceList.count <= 0 ? "暂无检测到设备" : "请选择设备")
                    }
                }
                .disabled(deviceService.deviceList.count <= 0)
                .disabled(instrumentService.isMonitoringPerformance)
                .frame(minWidth: 100)
            }
            
            ToolbarItem(placement: .navigation) {
                Menu {
                    Section("App") {
                        ForEach(deviceService.userApplist) { app in
                            Button(app.name) {
                                service.selectApp = app
                            }
                        }
                    }
                } label: {
                    Text(service.selectApp?.name ?? "请选择App")
                }
                .disabled(deviceService.userApplist.count <= 0)
                .disabled(instrumentService.isMonitoringPerformance)
                .frame(minWidth: 100)
            }
        }
        .onAppear {
            deviceService.refreshDeviceList()
        }
    }
}
