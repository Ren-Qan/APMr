//
//  Meuns.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/15.
//

import SwiftUI

struct Meuns<Label: View, Content: View>: View {
    @State var isPresent: Bool = false
    
    @ViewBuilder var label: () -> Label
    
    @ViewBuilder var popContent: () -> Content
    
    var body: some View {
        Button {
            isPresent.toggle()
        } label: {
            label()
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $isPresent, arrowEdge: .bottom) {
            popContent()
        }
    }
}
