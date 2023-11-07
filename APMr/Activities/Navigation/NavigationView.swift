//
//  NavigationView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import SwiftUI

struct NavigationView: View {
    @EnvironmentObject var navigation: ANavigation
    
    @EnvironmentObject var device: ADevice
    
    @EnvironmentObject var performance: CPerformance
    
    var body: some View {
        NavigationSplitView {
            List(selection: $navigation.selection) {
                Section("功能") {
                    ForEach(ANavigation.siders) { sider in
                        NavigationLink(sider.title, value: sider)
                    }
                }
            }
        } detail: {
            switch navigation.selection.state {
                case .performance:
                    IPerformanceView()
                        .environmentObject(device)
                        .environmentObject(performance)
                    
                case .launch:
                    ILaunchMonitorView()
                    
                default:
                    Text(navigation.selection.title + " In Progress")
            }
        }
        .navigationTitle(
            Text("")
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Menu {
                    ForEach(device.phoneList) { phone in
                        Button {
                            if let beforeDevice = device.selectPhone, beforeDevice.id == phone.id {
                                return
                            }
                            device.selectPhone = phone
                            device.selectApp = nil
                            device.userApplist = []
                            device.refreshApplist(phone)
//                            device.refreshRunningProcess(phone)
                        } label: {
                            Label(phone.name,
                                  systemImage: phone.type == .usb ? "cable.connector.horizontal" : "wifi")
                            .labelStyle(.titleAndIcon)
                        }
                    }
                } label: {
                    if let phone = device.selectPhone {
                        Text("\(phone.name)")
                        Image(systemName: phone.type == .usb ? "cable.connector.horizontal" : "wifi")
                    } else {
                        Text(device.phoneList.count <= 0 ? "暂无检测到设备" : "请选择设备")
                    }
                }
                .disabled(device.phoneList.count <= 0)
                .frame(minWidth: 100)
                .labelStyle(TitleAndIconLabelStyle.titleAndIcon)
            }
            
            ToolbarItem(placement: .navigation) {
                Menu {
                    if let app = device.lastSelectApp {
                        Section("Last Selection App") {
                            Button(app.name) {
                                device.selectApp = app
                            }
                        }
                    }
                    
                    Section("Menu") {
                        if device.userApplist.count > 0 {
                            Menu("Installed Apps") {
                                ForEach(device.userApplist) { app in
                                    Button(app.name) {
                                        device.selectApp = app
                                    }
                                }
                            }
                        }
                        
                        if device.runningProcess.count > 0 {
                            Menu("Running Processes") {
                                ForEach(device.runningProcess) { process in
                                    Button(process.name) {
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                } label: {
                    Text(device.selectApp?.name ?? "请选择")
                }
                .disabled(device.userApplist.count <= 0)
                .frame(minWidth: 100)
            }
        }
    }
}
