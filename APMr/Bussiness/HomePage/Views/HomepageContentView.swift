//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct HomepageContentView: View {
    @ObservedObject private var deviceService = HomepageDeviceService()
    
    @ObservedObject private var instrumentService = HomepageInstrumentsService()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center) {
                Spacer(minLength: 10)
                selectDevice
                Spacer(minLength: 10)
                selelctApp
                
                Spacer(minLength: 20)
                Text(instrumentService.sysmontap.title)
                CoordinateChartView(
                    items: instrumentService.sysmontap.items
                )
                .background {
                    Color.white
                }
                Spacer(minLength: 10)
                
                Text(instrumentService.opengl.title)
                CoordinateChartView(
                    items: instrumentService.opengl.items
                )
                .background {
                    Color.white
                }
            }
        }

        .onAppear {
            deviceService.refreshDeviceList()
        }
    }
    
    
   private var selectDevice: some View {
        HStack {
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
            .frame(width: 100)
            
            Button("RefreshDevice") {
                deviceService.refreshDeviceList()
            }
        }
        .offset(x: 20)
    }
    
    private var selelctApp: some View {
        HStack {
            Menu(deviceService.selectApp?.name ?? "请选择APP") {
                ForEach(deviceService.appList) { app in
                    Button(app.name) {
                        deviceService.selectApp = app
                    }
                }
            }
            .frame(width: 100)
            
            Button(deviceService.selectApp?.name ?? "selelct App") {
                if let app = deviceService.selectApp {
                    instrumentService.launch(app: app)
                }
                instrumentService.autoRequest()
            }
        }
        .offset(x: 20)
    }
}
