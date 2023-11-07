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
        fileprivate lazy var separator = Separator()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.adds([headline, panelSet])
            self.view.layer?.add(separator)
        }
        
        override func viewDidLayout() {
            let hH: CGFloat = 40
            if headline.frame.width != view.bounds.width {
                headline.frame = .init(x: 0, y: view.bounds.height - hH, width: view.bounds.width, height: hH)
            }
            
            if headline.frame.origin.y != view.bounds.height - hH {
                headline.frame.origin.y = view.bounds.height - hH
            }
            
            
            if panelSet.frame.width != view.bounds.width {
                panelSet.frame = .init(x: 0,
                                       y: 0,
                                       width: view.bounds.width,
                                       height: view.bounds.height - headline.frame.size.height)
            }
            
            if let w = view.layer?.frame.width, separator.frame.width != w {
                separator.frame = .init(x: 0, y: 0, width: w, height: 1)
            }
        }

        override func updateLayer() {
            view.layer?.backgroundColor = NSColor.box.BG2.cgColor
            separator.backgroundColor = NSColor.box.S1.cgColor
        }
    }
}

extension IPerformanceView.ICharts.NSISides.Cell {
    public func sync(_ shot: IPerformanceView.ICharts.NSISides.S) {
        headline.render(shot)
        panelSet.render(shot)
    }
}

extension IPerformanceView.ICharts.NSISides.Cell {
    fileprivate class Separator: CALayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
