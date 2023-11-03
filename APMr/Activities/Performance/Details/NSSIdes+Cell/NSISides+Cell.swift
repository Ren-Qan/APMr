//
//  NSISide.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/30.
//

import AppKit
import SwiftUI

extension IPerformanceView.ICharts.NSISides {
    class Cell: NSCollectionView.Cell {
        fileprivate lazy var headline = Headline()
        fileprivate lazy var panelSet = PanelSet()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.adds([headline, panelSet])
        }
        
        override func viewDidLayout() {
            if headline.frame.width != view.bounds.width {
                headline.frame = .init(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 50)
            }
            
            if panelSet.frame.width != view.bounds.width {
                panelSet.frame = .init(x: 0,
                                       y: 0,
                                       width: view.bounds.width,
                                       height: view.bounds.height - headline.frame.size.height)
            }
        
        }
    }
}

extension IPerformanceView.ICharts.NSISides.Cell {
    public func sync(_ shot: IPerformanceView.ICharts.NSISides.S) {
        headline.render(shot)
        panelSet.render(shot)
    }
}
