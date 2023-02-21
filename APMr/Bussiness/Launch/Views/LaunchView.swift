//
//  LaunchView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var launchService: LaunchInstrumentsService
    
    @State var serviceT: String = ""
    
    var body: some View {
        VStack {
            TextField("test", text: $serviceT)
            
            Button("test") {
                guard let device = service.selectDevice,
                      let app = service.selectApp else {
                    return
                }
                
                launchService.start(device) { success, service in
                    service.test(app: app, service: serviceT)
                }
            }
            
            Button("close") {
                launchService.close()
            }
            
            Button("Stop") {
                launchService.stopService()
            }
        }
    }
}

