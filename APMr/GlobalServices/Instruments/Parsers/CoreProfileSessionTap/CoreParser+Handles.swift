//
//  CoreParser+Handles.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/2.
//

import Foundation

extension CoreParser {
    struct Handle {
        
    }
}

extension CoreParser.Handle {
    class CallStack {
        public weak var delegate: CoreLiveCallStacksDelegate? = nil
        
        private var dylds: [DYLD] = []
        
        func generator(_ chunk: CoreParser.Chunk) {
            switch chunk.occasion {
                case .undefined: return
                    
                case .PERF_Event(let oc):
                    guard oc.frames.count > 0 else {
                        return
                    }
                    
                    var frames: [CSFrame] = []
                    
                    oc.frames.forEach { frame in
                        let i = find(frame)
                        
                        if i > 0 {
                            let dyld = dylds[i - 1]
                            let f = CSFrame(frame: frame,
                                             uuid: dyld.uuid,
                                             offset: frame - dyld.frame)
                            frames.append(f)
                        } else {
                            let f = CSFrame(frame: frame,
                                            uuid: nil,
                                            offset: nil)
                            frames.append(f)
                        }
                    }
                    
                    guard let event = chunk.events.first else {
                        return
                    }
                    let cs = CS(timestamp: event.timestamp,
                                tid: event.body.timestamp,
                                tpMap: chunk.tpMap,
                                frames: frames)
                    delegate?.callStack(cs)
                    
                case .DYLD_uuid_map_a(let oc):
                    let dyld = DYLD(frame: oc.loadAddr, uuid: oc.uuid)
                    insert(dyld)
                    
                case .DBG_DYLD_TIMING_LAUNCH_EXECUTABLE(let oc):
                    oc.mapAs.forEach { o in
                        let dyld = DYLD(frame: o.loadAddr, uuid: o.uuid)
                        insert(dyld)
                    }
            }
        }
        
        private func find(_ frame: Frame) -> Int {
            if dylds.count < 1 {
                return -1
            }
            
            for (index, dyld) in dylds.enumerated() {
                if dyld.frame > frame {
                    return index
                }
            }
            
            return dylds.count
        }
        
        private func insert(_ dyld: DYLD) {
            let index = find(dyld.frame)
            
            if index <= 0 {
                dylds.insert(dyld, at: 0)
            } else {
                let pre = dylds[index - 1]
                if pre.frame != dyld.frame {
                    dylds.insert(dyld, at: index)
                }
            }
        }
    }
}
