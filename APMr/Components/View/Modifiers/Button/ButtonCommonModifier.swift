//
//  ButtonCommonModifier.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/1.
//

import Foundation
import SwiftUI

struct ButtonCommonModifier: ViewModifier {
    typealias Body = Button
    
    var backColor: Color?
    
    var enable: Bool = true
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(
                ButtonCommonStyle(
                    backColor: backColor,
                    enable: enable
                )
            )
            .disabled(!enable)
    }
}

extension Button {
    func common(backColor: Color?, enable: Bool = true) -> some View {
        self.modifier(
                ButtonCommonModifier(
                    backColor: backColor,
                    enable: enable
                )
            )
    }
}
