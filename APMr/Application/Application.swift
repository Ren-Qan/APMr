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
//            Root()
//                .preferredColorScheme(.dark)
//                .monospaced()
//                .frame(minWidth: 1200)
//                .frame(minHeight: 400)
//                .background {
//                    Color.fabulaBack0
//                }
//                .onAppear {
//                    NSWindow.allowsAutomaticWindowTabbing = false
//                }

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
                        Toggle("切换显示模式", isOn: $schemeIsDark)
                    }
                }
                .preferredColorScheme(schemeIsDark ? .dark : .light)
#endif
        }
        .commandsRemoved()
    }
}
