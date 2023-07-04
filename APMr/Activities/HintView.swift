//
//  HintView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

extension IPerformanceView {
    struct HintView: NSViewRepresentable {
        func makeNSView(context: Context) -> IPerformanceView.NSHintView {
            let view = NSHintView()
            view.wantsLayer = true
            view.target = self
            return view
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSHintView, context: Context) {
            nsView.target = self
        }
    }
}

extension IPerformanceView {
    class NSHintView: NSView {
        fileprivate var target: HintView? = nil
    }
}


