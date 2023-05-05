//
//  IInstrumentsCoreProfileSessionTapModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/27.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    enum Tag: UInt32 {
        case sshot = 0x8002
        case images = 0x8004
        case kernelExtensions = 0x8005
        case config = 0x8006
        case kernel = 0x8008
        case machine = 0x8c00
        case cpuEvents = 0x8c01
        case cpuEvents2 = 0x8013
        case cpuEventsNull = 0x800e
        case rawVersion3 = 0x00001000
        case v3NullChunk = 0x00002000
        case v3Config = 0x00001b00
        case v3CpuHeaderTag = 0x00001c00
        case v3ThreadMap = 0x00001d00
        case v3RawEvents = 0x00001e00
    }

    struct KDHeaderV3 {
        var tag: UInt32 = 0
        var sub_tag: UInt32 = 0
        var length: UInt64 = 0
        var timebase_numer: UInt32 = 0
        var timebase_denom: UInt32 = 0
        var timestamp: UInt64 = 0
        var walltime_secs: UInt64 = 0
        var walltime_usecs: UInt32 = 0
        var timezone_minuteswest: UInt32 = 0
        var timezone_dst: UInt32 = 0
        var flags: UInt32 = 0
    }
        
    struct KDSubHeaderV3 {
        var tag: UInt32 = 0
        var major: UInt16 = 0
        var minor: UInt16 = 0
        var length: UInt64 = 0
    }

    struct KDCpuMapHeader {
        var version: UInt32 = 0
        var count: UInt32 = 0
    }

    struct KDCpuMap {
        var cpuId: UInt32 = 0
        var flags: UInt32 = 0
        var name = Data(capacity: 8)
        var args = Array<UInt32>(repeating: 0, count: 6)
    }

    struct KDHeaderV2 {
        var tag: UInt32 = 0
        var number_of_treads: UInt32 = 0
        var arg1: Int32 = 0
        var arg2: Int32 = 0
        var arg3: Int32 = 0
        var is_64bit: UInt32 = 0
        var tick_frequency: UInt64 = 0
    }

    struct KDThreadMap {
        var thread: UInt64 = 0
        var pid: UInt32 = 0
        var process = String()
    }

    struct KDEBUGEntry {
        var timestamp: UInt64 = 0
        var arg1: UInt64 = 0
        var arg2: UInt64 = 0
        var arg3: UInt64 = 0
        var arg4: UInt64 = 0
        var thread: UInt64 = 0
        var debug_id: UInt32 = 0
        var cpu_id: UInt32 = 0
        var unused: UInt64 = 0
        
        var event_id: UInt32 { debug_id & 0xfffffffc}
        var class_code: UInt32 { (debug_id >> 24) & 0xff }
        var subclass_code: UInt32 { (debug_id >> 16) & 0xff }
        var action_code: UInt32 { (debug_id >> 2) & 0x3fff }
        var func_code: UInt32 { debug_id & UInt32(0x00000003) }
    }
}

