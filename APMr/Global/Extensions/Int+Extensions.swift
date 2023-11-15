//
//  Int64+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/2.
//

import CoreFoundation

extension Int64 {
    var B: Double {
        return Double(self) / 8
    }
    
    var KB: CGFloat {
        return CGFloat(B) / 1024
    }
    
    var MB: CGFloat {
        return KB / 1024
    }
    
    var GB: CGFloat {
        return MB / 1024
    }
}

extension Int {
    var f: CGFloat {
        return CGFloat(self)
    }
}
