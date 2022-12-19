//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI
import Charts

struct ID: PerformanceCoordinateViewMarkProtocol {
    var x: Int
    var y: Int
    var tips: String
    var id: Int { x }
}

struct HomepageContentView: View {
    @StateObject private var deviceService = HomepageDeviceService()
    
    @StateObject private var instrumentService = HomepageInstrumentsService()
        
    @State private var selectDevice: DeviceItem? = nil
    
    @State private var selectApp: IInstproxyAppInfo? = nil
        
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 40) {
                makeCoordinateView(100, "CPU", instrumentService.cpu.datas)
                makeCoordinateView(100, "GPU", instrumentService.gpu.datas)
//                makeCoordinateView("Memory", [])
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            deviceService.refreshDeviceList()
        }
        .navigationTitle("")
        .frame(minWidth: 800)
        .frame(minHeight: 250)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                MenuButton(label: menuButtonLabel(selectDevice)) {
                    ForEach(deviceService.deviceList) { device in
                        Button {
                            selectDevice = device
                            deviceService.refreshApplist(device)
                            instrumentService.start(device)
                        } label: {
                            menuButtonLabel(device)
                        }
                    }
                }
                .frame(minWidth: 100)
            }
            
            if selectDevice != nil {
                ToolbarItem(placement: .navigation) {
                    MenuButton(label: Text(selectApp?.name ?? "请选择App")) {
                        ForEach(deviceService.userApplist) { app in
                            Button(app.name) {
                                selectApp = app
                            }
                        }
                    }
                    .disabled(deviceService.userApplist.count <= 0)
                }
            }
            
            if let app = selectApp {
                ToolbarItem(placement: .navigation) {
                    Button {
                        if !instrumentService.isRunningService {
                            instrumentService.launch(app: app)
                            instrumentService.autoRequest()
                        } else {
                            instrumentService.stopService()
                        }
                    } label: {
                        Image(systemName: instrumentService.isRunningService ? "stop.circle" : "record.circle")
                        Text(instrumentService.isRunningService ? "Stop" : "Start")
                    }
                    .disabled(instrumentService.isLinkingService)
                }
            }
        }
    }
        
    private func makeCoordinateView<Item>(_ maxY: Int, _ title: String, _ items: [Item]) -> some View where Item: PerformanceCoordinateViewMarkProtocol  {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .background {
                    Color.primary.opacity(0.1)
                        .cornerRadius(4)
                        .padding(.init(top: -1, leading: -5, bottom: -1, trailing: -5))
                }
                .padding(.leading, 15)
            
            PerformanceCoordinateView(maxY: maxY, items: items) { item, selectIndex in
                BarMark(x: .value("x", item.x),
                        y: .value("y", item.y))
                .foregroundStyle(selectIndex == item.x ? .green : .blue)
                .annotation {
                    if selectIndex == item.x {
                        Text("Selected Index : \(selectIndex)")
                    }
                }
            }
            .frame(height: 170)
        }
    }
    
    private func menuButtonLabel(_ devce: DeviceItem?) -> some View {
        HStack {
            if let devce = devce {
                Text(devce.deviceName)
                Spacer()
                Image(systemName: devce.type == .usb ? "cable.connector" : "wifi")
            } else {
                Text("请选择设备")
            }
        }
    }
}
