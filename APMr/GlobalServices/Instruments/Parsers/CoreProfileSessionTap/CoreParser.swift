//
//  CoreParser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/23.
//

import Foundation

class CoreParser {
    var tracePid: PID? = nil
    var traceCodes: [Int64 : String]? = nil
    var traceMachTime: IInstruments.DeviceInfo.MT? = nil
    private var threadMap: [TID : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var hp = TP()
}

extension CoreParser {
    func merge(_ threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap]) {
        self.threadMap.merge(threadMap) { current, _ in current }
    }
    
    func feeds(_ elements: [IInstruments.CoreProfileSessionTap.KDEBUGElement]) {
        queue.addOperation { [weak self] in
            elements.forEach { e in
                self?.feed(e)
            }
        }
    }
}

extension CoreParser {
    private func feed(_ element: IInstruments.CoreProfileSessionTap.KDEBUGElement) {
        let event = Event(body: element)
        if let events = hp.feed(event) {
            parse(events)
        }
    }
    
    public func parse(_ events: Events) {
        guard events.list.count > 0 else {
            return
        }
        let event = events.list[0]
        
        guard event.body.timestamp < UInt64(Int64.max),
              let time = traceMachTime?.format(time: Int64(event.body.timestamp)) else {
            return
        }
        
        guard let traceName = traceCodes?[Int64(event.body.event_id)] else {
            return
        }
        
        let thread = threadMap[event.body.thread]?.process ?? "[TID: \(event.body.thread)]"
        
        if traceName == "TRACE_STRING_GLOBAL" {
            let str = handleTraceStringGlobal(events)
            print("\(time) --- \(thread) --- \(traceName) : \(str)")
            return
        }
        
        print("\(time) --- \(thread) --- \(traceName)")
    }
    
    private func handleTraceStringGlobal(_ events: Events) -> String {
        var str = ""
        events.list.forEach { event in
            if event.body.func_code == .start {
                str = Data(event.body.data[16 ..< 32]).string(16)
            } else {
                str += event.body.data.string()
            }
        }
        
        return str
    }
}

extension CoreParser {
    class TP {
        private var map: [TID : TEvent] = [:]
        
        public func feed(_ event: Event) -> Events? {
            let funcID = event.body.func_code
            let tid = event.body.thread
            let eid = event.body.event_id
            
            if funcID == .start {
                if map[tid] == nil {
                    map[tid] = TEvent()
                }
            } else if funcID == .end {
                if map[tid] == nil || map[tid]?.events(eid) == nil {
                    return nil
                }
            }
            
            map[tid]?.feed(event)
            
            if funcID == .end {
                return map[tid]?.pop(eid)
            } else if funcID == .all || funcID == .none {
                let events = Events()
                events.feed(event)
                return events
            }
            return nil
        }
    }
    
    class TEvent {
        private var map: [EID : Events] = [:]
        
        func events(_ eId: EID) -> Events? {
            return map[eId]
        }
        
        func pop(_ eId: EID) -> Events? {
            let events = events(eId)
            map[eId] = nil
            return events
        }
        
        public func feed(_ event: Event) {
            let eid = event.body.event_id
            
            if event.body.func_code == .start {
                if events(eid) == nil {
                    map[eid] = Events()
                }
                map[eid]?.clean()
            }
            
            map.forEach { (key: EID, value: CoreParser.Events) in
                value.feed(event)
            }
        }
    }
    
    class Events {
        var list: [Event] = []
        
        func clean() {
            list = []
        }
        
        func feed(_ event: Event) {
            list.append(event)
        }
    }
    
    struct Event {
        let body:  IInstruments.CoreProfileSessionTap.KDEBUGElement
    }
}
