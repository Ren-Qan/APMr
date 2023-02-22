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
            Button("start") {
                guard let device = service.selectDevice else {
                    return
                }
                
                launchService.start(device) { success, service in

                }
            }
            
            Button("test") {
                launchService.test()
            }
            
            Button("test2") {
                guard let app = service.selectApp else {
                    return
                }
                launchService.core(app: app)
            }
        }
    }
}

