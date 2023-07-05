//
//  Entity.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/5.
//

import AppKit
import Combine

extension CPerformance {
    enum E {
        case cpu
        case gpu
        case fps
        case memory
        case network
        case io
        case diagnostic
        
        var name: String {
            switch self {
                case .memory:
                    return "Memory"
                case .network:
                    return "Network"
                case .io:
                    return "I/O"
                case .diagnostic:
                    return "Diagnostic"
                default:
                    return "\(self)".uppercased()
            }
        }
    }
}
