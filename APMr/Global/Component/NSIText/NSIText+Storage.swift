//
//  NSIText+Storage.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension NSIText {
    class Storage {
        public var notice: ((_ old: Int, _ new: Int) -> Void)? = nil
        
        public var frame: CGRect = .zero {
            didSet {
                if !oldValue.equalTo(frame) {
                    version += 1
                }
            }
        }
        
        public var text: String? = nil {
            didSet {
                let old = oldValue ?? ""
                let new = text ?? ""
                if old != new {
                    version += 1
                }
            }
        }
        
        public var align: Align = .left {
            didSet {
                if oldValue != align {
                    version += 1
                }
            }
        }
        
        public var lines: Int = 0 {
            didSet {
                if oldValue != lines {
                    version += 1
                }
            }
        }
        
        public var color: NSColor = .box.H1 {
            didSet {
                if oldValue != color {
                    version += 1
                }
            }
        }
        
        public var font: NSFont = .systemFont(ofSize: 14) {
            didSet {
                if oldValue != font {
                    version += 1
                }
            }
        }
        
        public var spacing: CGFloat = 0 {
            didSet {
                if oldValue != spacing {
                    version += 1
                }
            }
        }
        
        fileprivate(set) var version = 0 {
            didSet {
                if oldValue != version {
                    notice?(oldValue, version)
                }
            }
        }
    }
}
