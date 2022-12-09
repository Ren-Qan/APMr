//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct HomepageContentView: View {
//    @ObservedObject private var service = HomepageService()
    
    @ObservedObject private var deviceService = HomepageDeviceService()
    
    @ObservedObject private var instrumentService = HomepageInstrumentsService()
    
    var body: some View {
        VStack {
            Menu(deviceService.selectDevice?.deviceName ?? "请选择设备") {
                ForEach(deviceService.deviceList) { device in
                    Button("\(device.type)" + " : " + device.deviceName) {
                        deviceService.selectDevice = device
                        deviceService.refreshApplist()
                        if let iDevice = IDevice(device) {
                            instrumentService.start(iDevice)
                        }
                    }
                }
            }
            
            Spacer(minLength: 10)
            
            Menu(deviceService.selectApp?.name ?? "请选择APP") {
                ForEach(deviceService.appList) { app in
                    Button(app.name) {
                        deviceService.selectApp = app
                    }
                }
            }
            
            Button(deviceService.selectApp?.name ?? "selelct App") {
                if let app = deviceService.selectApp {
                    instrumentService.launch(app: app)
                    instrumentService.autoRequest()
                }
            }
            
            ScrollView {
                LazyVStack {
                    Spacer(minLength: 20)
                    Text(instrumentService.sysmontap.title)
                    CoordinateChartView(items: instrumentService.sysmontap.items)
                        .background {
                            Color.white
                        }
                    Spacer(minLength: 10)
                }
            }
        }
        .onAppear {
            deviceService.refreshDeviceList()
        }
    }
}
