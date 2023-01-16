//
//  CommonStyle.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/15.
//

import SwiftUI

struct ButtonCommonStyle: ButtonStyle {
    var backColor: Color?
    
    @State var isHoivering = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .padding(.horizontal, 10)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .background {
                if let backColor = backColor {
                    backColor.opacity(isHoivering ? 0.5 : 1)
                }
            }
            .onHover { isHover in
                isHoivering = isHover
            }
    }
}
