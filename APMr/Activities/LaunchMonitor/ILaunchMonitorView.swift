//
//  ILaunchMonitorView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/7.
//

import SwiftUI

struct ILaunchMonitorView: View {
    @State var value: Double = 0
    @State var iconName: String = ""
    @State var color: Color = .box.BLUE1
    var body: some View {
        VStack {
            Image(systemName: iconName, variableValue: value)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .foregroundColor(color)
            
            
            Slider(value: $value, in: 0 ... 1)
            
            TextField("", text: $iconName)
            
            ColorPicker("", selection: $color)
            
        }
    }
}
