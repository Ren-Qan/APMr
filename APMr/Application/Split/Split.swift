//
//  Split.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/6.
//

import SwiftUI

struct Split: View {
    @Binding var selection: AppSider
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("功能") {
                    ForEach(AppConfigs.siders) { sider in
                        NavigationLink(sider.title, value: sider)
                    }
                }
            }
        } detail: {
            switch selection.state {
                case.performance:
                    HomepageContentView()
                    
                default:
                    Text(selection.title)
            }
        }
    }
}
