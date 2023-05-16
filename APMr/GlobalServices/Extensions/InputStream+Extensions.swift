//
//  InputStream+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/16.
//

import Foundation

extension InputStream {
    func data(_ len: Int) -> Data {
        guard len > 0 else {
            return .init()
        }
        let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        read(dataP, maxLength: len)
        let data = Data(bytes: dataP, count: len)
        dataP.deallocate()
        return data
    }
}
