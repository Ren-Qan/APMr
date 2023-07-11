//
//  LaunchView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var deviceService: ADevice
    
    @EnvironmentObject var launchService: LaunchInstrumentsService
    
    @State var serviceT: String = ""
    
    var body: some View {
        VStack {
            Button("start") {
                guard let device = deviceService.selectPhone, let app = deviceService.selectApp else {
                    return
                }
                
                launchService.start(device) { success, service in
                    service.prepare(app)
                }
            }
            
            Button("launch") {
                guard let app = deviceService.selectApp else {
                    return
                }
                launchService.launch(app: app)
            }
            
            
            Button("STOP") {
                launchService.stop()
            }
        }
    }
}
