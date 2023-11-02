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
        lazy var label: NSTextField = {
            let textField = NSTextField()
            textField.wantsLayer = true
            textField.isBordered = false
            textField.isEditable = false
            textField.textColor = .white
            textField.alignment = .center
            textField.backgroundColor = .orange
            return textField
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(label)
        }
        
        override func viewDidLayout() {
            super.viewDidLayout()
            label.frame = view.bounds
        }
    }
}

extension IPerformanceView.ICharts.NSISides.Cell {
    public func sync(_ shot: IPerformanceView.ICharts.NSISides.S) {
        
    }
}
