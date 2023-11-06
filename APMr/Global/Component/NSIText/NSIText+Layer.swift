//
//  NSIText+Layer.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/6.
//

import AppKit

extension NSIText {    
    class Layer: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
