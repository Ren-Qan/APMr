//
//  Chart+Actor.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart {
    class Actor: ObservableObject {
        fileprivate(set) lazy var displayer = Displayer()
        
        fileprivate(set) lazy var hilighter = Highlighter()
        
        public func reset() {
            displayer.reset()
            hilighter.reset()
        }
    }
}
