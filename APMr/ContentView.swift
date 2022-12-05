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
    
    var y: CGFloat = 0
    
    var x = 0
}

struct ContentView: View {
    
    var instrument = IIntruments()
    
    var sysmontap = IInstrumentsSysmontap()
    
    var deviceInfo = IInstrumentsDeviceInfo()
    
    var opengl = IInstrumentsOpengl()
    
    @State private var items = [LandMarkItem]()
    
    @State private var btnText = "Connect"
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                Spacer(minLength: 20)
                
                Button(btnText) {
                    connectAction()
                    
                    
                }
                
                Spacer(minLength: 20)
                
                Section {
                    BarChartView(marks: items)
                        .frame(height: 150)
                        .padding(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                        .background {
                            Color.white
                        }
                } header: {
                    Text("CPU")
                }
                
                Spacer(minLength: 10)
            }
        }
    }
    
    
    private func connectAction() {
        btnText = "loading"
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
            btnText = "failed"
            return
        }
        
        if !instrument.isConnected, instrument.start(iDevice) {
            self.sysmontap.start(instrument)
            self.sysmontap.register(.setConfig)
            self.sysmontap.register(.start)
            self.sysmontap.autoRequest()
            
            self.sysmontap.callBack = { cpu, processes in
                
                let process = processes.Processes.first { (pid, values) in
                    if let name = (values as? Array<Any>)?.last as? String,
                       name == "WeChat" {
                        return true
                    }
                    return false
                }
                
                if let process = process,
                   let values = process.value as? Array<Any>,
                   let cpu = values[1] as? CGFloat {
                    let x = items.count
                    var item = LandMarkItem()
                    item.id = x
                    item.x = x
                    item.y = cpu
                    self.items.append(item)
                    
                    print("\(item.y) -- \(processes.type)")
                }
            }
            
            btnText = "success"
            return
        }
        btnText = "failed"
    }
}
