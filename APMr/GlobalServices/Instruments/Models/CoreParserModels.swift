//
//  CoreParserModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/1.
//

import Foundation

extension CoreParser {
    enum OccasionT {
        case undefined
        case PERF_Event(PERFOccasion)
        case DYLD_uuid_map_a(DyldUuidMapAOccasion)
        case DBG_DYLD_TIMING_LAUNCH_EXECUTABLE(DyldLaunchExecutableOccasion)
        
        init(_ chunk: Chunk) {
            guard let head = chunk.events.first,
                  let name = head.name else {
                self = .undefined
                return
            }
            
            self = .undefined

            switch name {
                case "PERF_Event":
                    if let o = PERFOccasion(chunk) {
                        self = .PERF_Event(o)
                    }
                    
                case "DYLD_uuid_map_a":
                    if let o = DyldUuidMapAOccasion(chunk) {
                        self = .DYLD_uuid_map_a(o)
                    }
                    
                case "DBG_DYLD_TIMING_LAUNCH_EXECUTABLE":
                    if let o = DyldLaunchExecutableOccasion(chunk) {
                        self = .DBG_DYLD_TIMING_LAUNCH_EXECUTABLE(o)
                    }
                    
                default: self = .undefined
            }
            
        }
    }
}

extension CoreParser {
    struct PERFOccasion {
        let actionId: Int64
        let samplers: [Sampler]
        let flages: [CallstackFlag]
        let frames: [Frame]
        
        init?(_ chunk: Chunk) {
            guard let head = chunk.events.first else {
                return nil
            }
            
            samplers = Sampler.fetch(head.body.data[0 ..< 8].int64)
            actionId = head.body.data[8 ..< 16].int64
            
            var _flages = [CallstackFlag]()
            var _frames = [Frame]()
            
            if samplers.contains([.SAMPLER_USTACK]) {
                let subEvents = chunk.events.filter { event in
                    event.name == "PERF_STK_UHdr"
                }
                
                if subEvents.count > 0,
                   let header = PerfStkUhdrOccasion(subEvents) {
                    let frames = chunk.events.flatMap { event in
                        if event.name == "PERF_STK_UData",
                        let data = PerfStkUDataOccasion([event])  {
                            return data.frames
                        }
                        return []
                    }
                    
                    let count = min(Int(header.frameCount), frames.count)
                    _frames = Array(frames[0 ..< count])
                    _flages = header.flags
                }
            }
            
            flages = _flages
            frames = _frames
        }
    }
    
    struct PerfStkUhdrOccasion {
        let flags: [CallstackFlag]
        let frameCount: Int64
        
        init?(_ chunk: Chunk) {
            self.init(chunk.events)
        }
        
        init?(_ events: [Event]) {
            guard let head = events.first else {
                return nil
            }
            
            flags = CallstackFlag.fetch(head.body.data[0 ..< 8].int64)
            frameCount = head.body.data[8 ..< 16].int64
        }
    }
    
    struct PerfStkUDataOccasion {
        let frames: [Frame]
        
        init?(_ chunk: Chunk) {
            self.init(chunk.events)
        }
        
        init?(_ events: [Event]) {
            guard let head = events.first else {
                return nil
            }
            
            var _frames = [Frame]()
            var base = 0
            (0 ..< 4).forEach { _ in
                _frames.append(head.body.data[base ..< base + 8].int64)
                base += 8
            }
            frames = _frames
        }
    }
}


extension CoreParser {
    struct DyldLaunchExecutableOccasion {
        let mainExecutableMh: Frame
        let mapAs: [DyldUuidMapAOccasion]
        
        init?(_ chunk: Chunk) {
            guard let head = chunk.events.first else {
                return nil
            }
            
            mainExecutableMh = head.body.data[0 ..< 8].int64
            var _mapAs = chunk.events.compactMap { event in
                let names = ["DYLD_uuid_map_a", "DYLD_uuid_shared_cache_a"]
                if let name = event.name, names.contains([name]),
                   let mapA = DyldUuidMapAOccasion([event]) {
                    return mapA
                }
                return nil
            }
            _mapAs.sort { l, r in l.loadAddr < r.loadAddr }
            mapAs = _mapAs
        }
    }
    
    struct DyldUuidMapAOccasion {
        let uuid: UUID
        let loadAddr: Frame
        let fsid: Int64
        
        init?(_ chunk: Chunk) {
            self.init(chunk.events)
        }
        
        init?(_ events: [Event]) {
            guard let head = events.first,
            let uuid = Data(head.body.data[0 ..< 16]).uuid else {
                return nil
            }
            
            self.uuid = uuid
            self.loadAddr = head.body.data[16 ..< 24].int64
            self.fsid = head.body.data[24 ..< 32].int64
        }
    }
}

extension CoreParser {
    enum Sampler: Int64, CaseIterable {
        case SAMPLER_TH_INFO = 0x01
        case SAMPLER_TH_SNAPSHOT = 0x02
        case SAMPLER_KSTACK = 0x04
        case SAMPLER_USTACK = 0x08
        case SAMPLER_PMC_THREAD = 0x10
        case SAMPLER_PMC_CPU = 0x20
        case SAMPLER_PMC_CONFIG = 0x40
        case SAMPLER_MEMINFO = 0x80
        case SAMPLER_TH_SCHEDULING = 0x100
        case SAMPLER_TH_DISPATCH = 0x200
        case SAMPLER_TK_SNAPSHOT = 0x400
        case SAMPLER_SYS_MEM = 0x800
        case SAMPLER_TH_INSCYC = 0x1000
        case SAMPLER_TK_INFO = 0x2000
        
        static func fetch(_ flag: Int64) -> [Sampler] {
            return allCases.filter { s in
                return (s.rawValue & flag) != 0
            }
        }
    }
    
    enum CallstackFlag: Int64, CaseIterable {
        case CALLSTACK_VALID = 0x01
        case CALLSTACK_DEFERRED = 0x02
        case CALLSTACK_64BIT = 0x04
        case CALLSTACK_KERNEL = 0x08
        case CALLSTACK_TRUNCATED = 0x10
        case CALLSTACK_CONTINUATION = 0x20
        case CALLSTACK_KERNEL_WORDS = 0x40
        case CALLSTACK_TRANSLATED = 0x80
        case CALLSTACK_FIXUP_PC = 0x100
        
        static func fetch(_ flag: Int64) -> [CallstackFlag] {
            return allCases.filter { s in
                return (s.rawValue & flag) != 0
            }
        }
    }
}
