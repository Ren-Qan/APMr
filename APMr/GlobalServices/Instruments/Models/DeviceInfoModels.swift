//
//  DeviceInfoModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/8.
//

import Foundation

extension IInstruments.DeviceInfo {
    struct MT {
        var mach_absolute_time: Int64
        var mach_timebase_number: Int64
        var mach_timebase_denom: Int64
        
        var mach_time_factor: CGFloat {
            CGFloat(self.mach_timebase_number) / CGFloat(self.mach_timebase_denom)
        }
        
        func format(time: Int64) -> CGFloat {
            return CGFloat(time - mach_absolute_time) * mach_time_factor
        }
    }
}
