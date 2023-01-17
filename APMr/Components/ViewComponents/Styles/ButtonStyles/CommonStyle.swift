//
//  CommonStyle.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/15.
//

import SwiftUI

struct ButtonCommonStyle: ButtonStyle {
    var backColor: Color?
    
    var enable: Bool = true
    
    @State private var isHoivering = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .padding(.horizontal, 10)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .background {
                backColor?.opacity(isHoivering ? 0.5 : 1)
            }
            .opacity(enable ? 1 : 0.3)
            .onHover { isHover in
                if enable {
                    isHoivering = isHover
                }
                
                if isHover {
                    if !enable {
                        NSCursor.operationNotAllowed.set()
                    }
                } else {
                    NSCursor.arrow.set()
                }
            }
        
    }
}
