//
//  HomePageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct HomePageContentView: View {
    private var service = HomePageService()
    
    @State private var devices: [DeviceItem] = []
    @State private var selectDevice: DeviceItem? = nil
    
    var body: some View {
        VStack {
            Menu(menuTitle) {
                ForEach(devices) { item in
                    Button("\(item.type)" + ": \(item.udid)") {
                        selectDevice = item
                    }
                }
            }
            
            Button("statr") {
                startService()
            }
            
            ScrollView {
                LazyVStack {
                    Spacer(minLength: 20)
                    Text("CPU")
                    CoordinateChartView(items: [])
                        .background {
                            Color.white
                        }
                    Spacer(minLength: 10)
                }
            }
        }
        .onAppear {
            MobileManager.share.refreshDeviceList()
            self.devices = MobileManager.share.deviceList
            NotificationCenter.default.addObserver(forName: MobileManager.subscribeChangedNotification, object: nil, queue: nil) { _ in
                MobileManager.share.refreshDeviceList()
                self.devices = MobileManager.share.deviceList
            }
        }
    }
    
    
    private var menuTitle: String {
        if let device = selectDevice {
            return "\(device.type)" + ": \(device.udid)"
        }
        return "请选择设备"
    }
    
    private func startService() {
        if let selectDevice = selectDevice,
           let idevice = IDevice(selectDevice),
           service.start(idevice){
            service.autoRequestChart()
        }
    }
}
