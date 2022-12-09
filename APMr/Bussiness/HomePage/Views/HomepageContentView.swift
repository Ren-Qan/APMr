//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct HomepageContentView: View {
    @ObservedObject private var service = HomepageService()
    
    var body: some View {
        VStack {
            Menu(service.device.selectDevice?.deviceName ?? "请选择设备") {
                ForEach(service.device.deviceList) { device in
                    Button("\(device.type)" + " : " + device.deviceName) {
                        service.device.selectDevice = device
                        service.device.refreshApplist()
                        if let iDevice = IDevice(device) {
                            service.insturment.start(iDevice)
                        }
                    }
                }
            }
            
            Spacer(minLength: 10)
            
            Menu(service.device.selectApp?.name ?? "请选择APP") {
                ForEach(service.device.appList) { app in
                    Button(app.name) {
                        service.device.selectApp = app
                    }
                }
            }
            
            Button(service.device.selectApp?.name ?? "selelct App") {
                if let app = service.device.selectApp {
                    service.insturment.launch(app: app)
                    service.insturment.autoRequest()
                }
            }
            
            ScrollView {
                LazyVStack {
                    Spacer(minLength: 20)
                    Text(service.insturment.sysmontap.title)
                    CoordinateChartView(items: service.insturment.sysmontap.items)
                        .background {
                            Color.white
                        }
                    Spacer(minLength: 10)
                }
            }
        }
        .onAppear {
            service.device.refreshDeviceList()
        }
    }
}
