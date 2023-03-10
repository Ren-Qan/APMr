//
//  Application.swift
//  APMr
//
//  Created by 任玉乾 on 2022/11/30.
//

import SwiftUI

@main
struct Application: App {
    var body: some Scene {
        WindowGroup {
            HomepageView()
                .preferredColorScheme(.dark)
                .monospaced()
                .frame(minWidth: 1200)
                .frame(minHeight: 600)
                .background {
                    Color.fabulaBack0
                }
        }
    }
}
