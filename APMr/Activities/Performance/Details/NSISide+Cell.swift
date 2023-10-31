//
//  NSISide.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/30.
//

import AppKit

extension IPerformanceView.ICharts.NSISides {
    class Cell: NSCollectionView.Cell {
        lazy var label: NSTextField = {
            let textField = NSTextField()
            textField.wantsLayer = true
            textField.isBordered = false
            textField.isEditable = false
            textField.textColor = .black
            textField.alignment = .center
            textField.backgroundColor = .random.withAlphaComponent(0.1)
            
            let tap = NSClickGestureRecognizer(target: self, action: #selector(click))
            self.view.addGestureRecognizer(tap)
            
            return textField
        }()
        
        var closure: (() -> Void)? = nil
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(label)
        }
        
        override func viewDidLayout() {
            super.viewDidLayout()
            label.frame = view.bounds
        }
        
        @objc private func click() {
            closure?()
        }
    }
}
