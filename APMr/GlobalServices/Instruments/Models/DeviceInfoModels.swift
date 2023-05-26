//
//  DeviceInfoModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/8.
//

import Foundation

extension IInstruments.DeviceInfo {
    struct MT {
        let mach_absolute_time: Int64
        let mach_timebase_number: Int64
        let mach_timebase_denom: Int64
        let usecs_since_epoch: CGFloat
        
        var mach_time_factor: CGFloat {
            CGFloat(self.mach_timebase_number) / CGFloat(self.mach_timebase_denom * 1000)
        }
        
        func format(time: Int64) -> String {
            let offset = CGFloat(time - mach_absolute_time) * mach_time_factor
            let timeStamp = (usecs_since_epoch + offset) / 1000000
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            formatter.timeZone = .current
        
            let date = Date(timeIntervalSince1970: timeStamp)
            let dateString = formatter.string(from: date)
            
            if let text = "\(timeStamp)".split(separator: ".").last, text.count > 3 {
                let suffix = text.suffix(text.count - 3)
                return dateString + suffix
            }
            return dateString
        }
    }
}
