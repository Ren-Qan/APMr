//
//  DispatchQueue+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/27.
//

import Foundation

extension DispatchQueue {
   static func mainAsync(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}
