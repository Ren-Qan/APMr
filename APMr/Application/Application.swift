//
//  Application.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI

@main
struct Application: App {
    @State var currentState = AppConfigs.siders.first!
    
    var body: some Scene {
        WindowGroup {
            Split(selection: $currentState)
        }
    }
}
