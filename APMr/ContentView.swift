//
//  ContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI
import LibMobileDevice

struct LandMarkItem: Identifiable, Hashable {
    var id = 0
}

struct SectionItem {
    
}

struct ContentView: View {
    
    var instrument = IIntruments()
    
    var sysmontap = IInstrumentsSysmontap()
    
    var deviceInfo = IInstrumentsDeviceInfo()
    
    var opengl = IInstrumentsOpengl()
    
     var i = 0
    
    @State private var items = [LandMarkItem]()
    
    private var item: LandMarkItem = .init()
    
//    @state privat var sections = [Section]()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("click") {
                items.append(.init(id: .random(in: 0 ..< 100)))
            }
            
//            List(items) { item in
//                Text("\(item.id)")
//            }
            
            
            Table(items) {
                TableColumn("1") { i in
                    Text("\(i.id)")
                }
                
                TableColumn("1") { i in
                    Text("\(i.id)")
                }
                
                TableColumn("1") { i in
                    Text("\(i.id)")
                }
                
                TableColumn("1") { i in
                    Text("\(i.id)")
                }
                
                TableColumn("1") { i in
                    Text("\(i.id)")
                }
            }

            
        }
        .padding()
    }
    
    
    func clickAction() {
        if instrument.isConnected {
//            self.sysmontap.request()
//            self.deviceInfo.request()
//            self.opengl.request()
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
//            self.sysmontap.start(instrument)
//            self.sysmontap.register(.setConfig)
//            self.sysmontap.register(.start)
//
//            self.deviceInfo.start(instrument)
//            self.deviceInfo.register(.runningProcesses)
            
            self.opengl.start(instrument)
            self.opengl.register(.startSampling)
            
            return
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
