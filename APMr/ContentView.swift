//
//  ContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI
import LibMobileDevice
import Charts


struct LandMarkItem: Identifiable, Hashable {
    var id = 0
    
    var y = 0
    
    var x = 0
}

struct ContentView: View {
    
    var instrument = IIntruments()
    
    var sysmontap = IInstrumentsSysmontap()
    
    var deviceInfo = IInstrumentsDeviceInfo()
    
    var opengl = IInstrumentsOpengl()
    
    @State private var items = [LandMarkItem]()
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                Spacer(minLength: 20)
                
                Button("Connect") {
                    connectAction()
                }
                
                Spacer(minLength: 20)
                
                Section {
                    BarChartView(marks: items)
                        .frame(height: 150)
                        .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                } header: {
                    Text("CPU")
                }
                
                Spacer(minLength: 10)
                
                Section {
                    BarChartView(marks: items)
                        .frame(height: 150)
                        .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                } header: {
                    Text("GPU")
                }
            }
        }
    }
    
    
    private func connectAction() {
        if MobileManager.share.deviceList.count < 2 {
            MobileManager.share.refreshDeviceList()
        }
        
        
        let device = MobileManager.share.deviceList.first { item in
            if item.type == .usb {
                return true
            }
            return false
        }
        
        guard let device = device,
              let iDevice = IDevice(device) else {
            return
        }
        
        if !instrument.isConnected, instrument.start(iDevice) {
            self.sysmontap.start(instrument)
            self.sysmontap.register(.setConfig)
            self.sysmontap.register(.start)
            self.sysmontap.autoRequest()
            return
        }
    }
}
