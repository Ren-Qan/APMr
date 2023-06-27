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
    
    var uint8: UInt8 {
        return withUnsafeBytes { $0.load(as: UInt8.self) }
    }
    
    var uint16: UInt16 {
        return withUnsafeBytes { $0.load(as: UInt16.self) }
    }
    
    var uint32: UInt32 {
        return withUnsafeBytes { $0.load(as: UInt32.self) }
    }
    
    var uint64: UInt64 {
        return withUnsafeBytes { $0.load(as: UInt64.self) }
    }
    
    var int64: Int64 {
        return withUnsafeBytes { $0.load(as: Int64.self) }
    }
    
    var uuid: UUID? {
        guard count >= 16 else {
            return nil
        }
        
        return withUnsafeBytes {
            guard let baseAddress = $0.bindMemory(to: UInt8.self).baseAddress else {
                return nil
            }
            return NSUUID(uuidBytes: baseAddress) as UUID
        }
    }
}
