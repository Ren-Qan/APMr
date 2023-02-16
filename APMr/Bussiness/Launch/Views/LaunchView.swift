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
    
    var body: some View {
        VStack {
            Button("test") {
                guard let device = service.selectDevice,
                      let app = service.selectApp else {
                    return
                }
                launchService.start(device) { success, service in
                    service.autoReceive()
                    service.test(app: app)
                }
            }
            
            Button("close") {
                launchService.close()
            }
        }
    }
}

