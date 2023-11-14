//
//  Application.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI

@main
struct Application: App {
    @StateObject private var navigation = ANavigation()
    
    @StateObject private var device = ADevice()
    
    @StateObject private var performance = CPerformance()
    
    #if DEBUG
    @State private var schemeIsDark: Bool = false
    #endif
    
    var body: some Scene {
        WindowGroup {
            NavigationView()
                .environmentObject(navigation)
                .environmentObject(device)
                .environmentObject(performance)
                .monospaced()
                .frame(minWidth: 1200)
                .frame(minHeight: 400)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
#if DEBUG
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button("切换显示模式") {
                            schemeIsDark.toggle()
                        }
                    }
                }
                .preferredColorScheme(schemeIsDark ? .dark : .light)
#endif
        }
        .commandsRemoved()
    }
}
