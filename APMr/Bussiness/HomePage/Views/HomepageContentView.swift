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
                barChart(instrumentService.cpu.title,
                         instrumentService.cpu.yMax,
                         instrumentService.cpu.datas)

//                barChart(instrumentService.gpu.title,
//                         instrumentService.gpu.yMax,
//                         instrumentService.gpu.datas)
//
//                lineChart(instrumentService.memory.title,
//                          Int(CGFloat(instrumentService.memory.yMax) / 0.8),
//                          instrumentService.memory.datas)
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
        }
        .onAppear {
            deviceService.refreshDeviceList()
        }
        .frame(minWidth: 800)
        .frame(minHeight: 250)
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                MenuButton(label: menuButtonLabel(selectDevice)) {
                    ForEach(deviceService.deviceList) { device in
                        Button {
                            selectDevice = device
                            deviceService.refreshApplist(device)
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
            
            if let app = selectApp, let device = selectDevice {
                ToolbarItem(placement: .navigation) {
                    Button {
                        if !instrumentService.isRunningService {
                            instrumentService.start(device) { success, service in
                                service.autoRequest()
                                service.launch(app: app)
                            }
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
        
    private var navigationTitle: String {
        if instrumentService.selectPid == 0 {
            return ""
        }
        return "RunningPid : " + String(instrumentService.selectPid)
    }
    
    private func barChart<Item>(_ title: String, _ maxY: Int, _ items: [Item]) -> some View where Item: PerformanceCoordinateViewMarkProtocol  {
        return makeChart(title, maxY: maxY, items) { item, selectIndex in
            BarMark(x: .value("x", item.x),
                    y: .value("y", item.y))
            .foregroundStyle(selectIndex == item.x ? .green : .blue)
            .annotation {
                if selectIndex == item.x {
                    Text(item.tips)
                }
            }
        }
    }
    
    private func lineChart(_ title: String, _ maxY: Int, _ items: [HomepageLineCharItem]) -> some View  {
        return makeChart(title, maxY: maxY, items) { item, selectIndex in
            LineMark(
                x: .value(item.xAxisKey, item.x),
                y: .value(item.yAxisKey, item.y)
            )
            .foregroundStyle(item.xAxisKey.contains("res") ? .green : .blue)
        }
    }
    
    private func makeChart<Item, Mark>(_ title: String, maxY: Int, _ items: [Item], _ mark: @escaping (Item, Int) -> Mark) -> some View where Item: PerformanceCoordinateViewMarkProtocol, Mark: ChartContent {
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
                .foregroundColor(.fabulaFore1)
            
            PerformanceCoordinateView(maxY: maxY, items: items) { item, selectIndex in
                mark(item, selectIndex)
            }
            .frame(height: 180)
            .background {
                Color.fabulaBack1
            }
        }
    }
    
    private func menuButtonLabel(_ devce: DeviceItem?) -> some View {
        HStack {
            if let devce = devce {
                Text(devce.deviceName)
                Spacer()
                Image(systemName: devce.type == .usb ? "cable.connector" : "wifi")
            } else {
                Text(deviceService.deviceList.count > 0 ? "请选择设备" : "未监测到设备")
            }
        }
    }
}
