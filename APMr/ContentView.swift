//
//  ContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI
import LibMobileDevice

struct ContentView: View {
        
     var instrument = IIntruments()
    
     var sysmontap = IInstrumentsSysmontap()
    
     var deviceInfo = IInstrumentsDeviceInfo()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("click") {
                
                DispatchQueue.global().async {
                    MobileManager.share.refreshDeviceList()
                    self.clickAction()
                }
            }
        }
        .padding()
    }
    
    
    func clickAction() {
        if instrument.isConnected {
            self.sysmontap.request()
            self.deviceInfo.request()
            return
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
                            
            self.deviceInfo.start(instrument)
            self.deviceInfo.register(.runningProcesses)
                        
            return
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
