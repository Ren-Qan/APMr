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
        
        func timestamp(_ time: Int64) -> CGFloat {
            let offset = CGFloat(time - mach_absolute_time) * mach_time_factor
            let timeStamp = (usecs_since_epoch + offset) / 1000000
            return timeStamp
        }
    }
    
    struct Process: Identifiable {
        let name: String
        let pid: PID
        let bundleId: String
        let isApplication: Bool
        var id: PID { pid }
    }
}

