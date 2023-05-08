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
            CGFloat(mach_time_factor) / CGFloat(mach_timebase_denom)
        }
    }
}
