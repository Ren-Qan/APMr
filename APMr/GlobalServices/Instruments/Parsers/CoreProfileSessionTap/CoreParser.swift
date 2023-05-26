//
//  CoreParser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/23.
//

import Foundation

class CoreParser {
    var tracePid: UInt32? = nil
    var traceCodes: [Int64 : String]? = nil
    var traceMachTime: IInstruments.DeviceInfo.MT? = nil
    
    private var threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
    private var traces = TP()
    private var events = TP()
}

extension CoreParser {
    func merge(_ threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap]) {
        self.threadMap.merge(threadMap) { current, _ in current }
    }
    
    func feed(_ element: IInstruments.CoreProfileSessionTap.KDEBUGElement) {
        //        let name = traceCodes?[Int64(element.event_id)] ?? String(format: "0x%X", element.event_id)
        //        let event = Event(trace_name: name, element: element)
        //        if let _ = TRACE(rawValue: name) {
        //            traces.feed(event)
        //            return
        //        }
        //        events.feed(event)
        
        guard let time = traceMachTime?.format(time: Int64(element.timestamp)) else {
            return
        }
        
        guard let code = traceCodes?[Int64(element.event_id)] else {
            return
        }
        
        let process = threadMap[UInt64(element.thread)]?.process ?? String(format: "0x%X", element.thread)
        
        print("[\(time)] - \(process) - \(code)")
    }
    
    private func trace(_ t: TRACE, _ e: IInstruments.CoreProfileSessionTap.KDEBUGElement) {
        if t == .TRACE_DATA_NEWTHREAD {
            let tid = e.data[0 ..< 8].uint32
            let pid = e.data[8 ..< 16].uint32
            if let threadMap = threadMap.first(where: { thread in
                return thread.value.pid == pid
            }) {
                var thread = threadMap.value
                thread.thread = UInt64(tid)
                self.threadMap[UInt64(tid)] = thread
            }
        } else if t == .TRACE_STRING_EXEC {
            
        }
    }
}


extension CoreParser {
    class TP {
        private var teMap: [UInt32 : TE] = [:]
        
        func feed(_ event: Event) {
            let threadID = UInt32(event.element.thread)
            if event.FUNC == .start {
                if teMap[threadID] == nil {
                    teMap[threadID] = .init(threadID)
                }
            } else if event.FUNC == .end {
                guard let te = teMap[threadID],
                      let _ = te.eventMap[event.element.event_id] else {
                    return
                }
            }
            
            let te = teMap[threadID]
            te?.feed(event)
            
            if event.FUNC == .start {
                return
            }
            
            let events = te?.eventMap[event.element.event_id]
            
            if event.FUNC == .end {
                te?.eventMap[event.element.event_id] = nil
            }

        }
    }
    
    class TE {
        let threadId: UInt32
        var thread: IInstruments.CoreProfileSessionTap.KDThreadMap? = nil
        var eventMap: [UInt32 : Events] = [:] // [eventID : Events]
        
        init(_ id: UInt32) {
            self.threadId = id
        }
        
        func feed(_ event: Event) {
            if event.FUNC == .start {
                if eventMap[event.element.event_id] == nil {
                    eventMap[event.element.event_id] = Events()
                }
                let events = eventMap[event.element.event_id]
                events?.list.removeAll()
                
                eventMap.values.forEach { events in
                    events.list.append(event)
                }
            } else if event.FUNC == .none || event.FUNC == .all {
                eventMap[event.element.event_id]?.list.append(event)
            } else {
                eventMap.values.forEach { events in
                    events.list.append(event)
                }
            }
        }
    }
    
    class Events {
        var list: [Event] = []
        
        func feed(_ event: Event) {
            if event.FUNC == .end {
                
            } else {
                list.append(event)
            }
        }
    }
    
    struct Event {
        let trace_name: String
        let element: IInstruments.CoreProfileSessionTap.KDEBUGElement
        
        var FUNC: DBGFUNC { return .init(element.func_code)! }
        
        enum DBGFUNC {
            case none
            case start
            case end
            case all
            
            init?(_ value: UInt32) {
                switch value {
                    case 0: self = .none
                    case 1: self = .start
                    case 2: self = .end
                    case 3: self = .all
                    default: return nil
                }
            }
        }
    }
}

extension CoreParser {
    enum TRACE: String {
        case TRACE_DATA_NEWTHREAD
        case TRACE_DATA_EXEC
        case TRACE_DATA_THREAD_TERMINATE
        case TRACE_DATA_THREAD_TERMINATE_PID
        case TRACE_STRING_GLOBAL
        case TRACE_STRING_NEWTHREAD
        case TRACE_STRING_EXEC
        case TRACE_STRING_PROC_EXIT
        case TRACE_STRING_THREADNAME
        case TRACE_STRING_THREADNAME_PREV
    }
}
