//
//  ILaunchMonitorView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/7.
//

import SwiftUI
import AppKit

struct ILaunchMonitorView: View {
    @State var angle: Double = 0
    @State var x: CGFloat = 0
    @State var y: CGFloat = 0
    @State var z: CGFloat = 0
    
    @State var ax: CGFloat = 0.5
    @State var ay: CGFloat = 0.5
    
    var body: some View {
        VStack {
            Text("Angle: \(angle) x: \(x) y: \(y) z: \(z) ax: \(ax) ay: \(ay)")
            NSIamge(angle: angle, x: x, y: y, z: z, ax: ax, ay: ay)
                .frame(maxWidth: 200)
                .frame(maxHeight: 200)
            Button("Reset") {
                x = 0
                y = 0
                z = 1
                angle = 0
                ax = 0.5
                ay = 0.5
            }
            Slider(value: $angle, in: -2 ... 2)
            Slider(value: $x, in: 0 ... 360)
            Slider(value: $y, in: 0 ... 360)
            Slider(value: $z, in: 0 ... 360)
            Slider(value: $ax, in: 0 ... 1)
            Slider(value: $ay, in: 0 ... 1)
        }
    }
}

struct NSIamge: NSViewRepresentable {
    var angle: Double
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
    
    var ax: CGFloat
    var ay: CGFloat
    
    typealias NSViewType = NSImageView
    
    func makeNSView(context: Context) -> NSViewType {
        let nsView = NSViewType()
        nsView.wantsLayer = true
        nsView.symbol("chevron.right").mode(.fit).background(.random)
        setup(nsView)
        return nsView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        setup(nsView)
    }
    
    private func setup(_ nsView: NSViewType) {
        nsView.layer?.anchor(.init(x: ax, y: ay))
        nsView.layer?.transform = CATransform3DMakeRotation(angle * .pi, x, y, z)
    }
}
