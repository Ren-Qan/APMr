//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct HomepageContentView: View {
    @ObservedObject private var service = HomepageService()
    
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
            
            Button("start") {
                startService()
            }
            
            ScrollView {
                LazyVStack {
                    Spacer(minLength: 20)
                    Text(service.gpu.text)
                    CoordinateChartView(items: service.gpu.items)
                        .background {
                            Color.white
                        }
                    Spacer(minLength: 10)
                }
            }
        }
        .onAppear {
            reloadDeviceList()
            NotificationCenter.default.addObserver(forName: MobileManager.subscribeChangedNotification, object: nil, queue: nil) { _ in
                reloadDeviceList()
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
            service.autoRequest()
        }
    }
    
    private func reloadDeviceList() {
        MobileManager.share.refreshDeviceList()
        devices = MobileManager.share.deviceList
    }
}
