//
//  Data+Extension.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/10.
//

import Foundation

extension Data {
    func string(_ len: Int = 32) -> String {
        var i = 0
        var cString = [UInt8]()
        while i < len, i < count, self[i] != 0 {
            cString.append(self[i])
            i += 1
        }
        cString.append(0)
        return String(cString: cString)
    }
}
