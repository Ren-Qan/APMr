//
//  CoreParser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/23.
//

import Foundation

protocol CoreParserDelegate: NSObjectProtocol {
    var traceCodesMap: [TraceID : String]? { get }
    
    var traceMachTime: IInstruments.DeviceInfo.MT? { get }

    func responsed(_ chunk: CoreParser.Chunk)
}

class CoreParser {
    public weak var delegate: CoreParserDelegate? = nil
    
    private lazy var tPMap: [TID : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
    private lazy var tEvent = ThreadEvent()
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

extension CoreParser {
    func parpare() {
        tPMap = [:]
        tEvent.clean()
    }
    
    func merge(_ threadMap: [TID : IInstruments.CoreProfileSessionTap.KDThreadMap]) {
        self.tPMap.merge(threadMap) { current, _ in current }
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
        guard element.timestamp < UInt64(Int64.max),
              let timestamp = delegate?.traceMachTime?.timestamp(Int64(element.timestamp)) else {
            return
        }
        
        let event = Event(body: element,
                          name: delegate?.traceCodesMap?[TraceID(element.event_id)],
                          timestamp: timestamp)
        if let chunk = tEvent.feed(event), generator(chunk) {
            delegate?.responsed(chunk)
            
            switch chunk.occasion {
                case .undefined: return
                default: print(chunk)
            }
        }
    }
    
    public func generator(_ chunk: Chunk) -> Bool {
        guard let head = chunk.events.first else {
            return false
        }
        
        chunk.tpMap = tPMap[head.body.thread]
        chunk.occasion = .init(chunk)
        
        return true
    }
}

extension CoreParser {
    fileprivate class ThreadEvent {
        var map: [TID : EEvent] = [:]
        
        func clean() {
            map = [:]
        }
        
        func feed(_ event: Event) -> Chunk? {
            let funcID = event.fCode
            let tid = event.body.thread
            let eid = event.body.event_id
            
            if funcID == .start {
                if map[tid] == nil {
                    map[tid] = EEvent()
                }
            } else if funcID == .end {
                if map[tid] == nil || map[tid]?.chunk(eid) == nil {
                    return nil
                }
            }
            
            map[tid]?.feed(event)
            
            if funcID == .end {
                return map[tid]?.pop(eid)
            } else if funcID == .all || funcID == .none {
                let chunk = Chunk()
                chunk.feed(event)
                return chunk
            }
            return nil
        }
    }
    
    fileprivate class EEvent {
        var map: [EID : Chunk] = [:]
        
        func chunk(_ eId: EID) -> Chunk? {
            return map[eId]
        }
        
        func pop(_ eId: EID) -> Chunk? {
            let chunk = chunk(eId)
            map[eId] = nil
            return chunk
        }
        
        func feed(_ event: Event) {
            let eid = event.body.event_id
            
            if event.fCode == .start {
                map[eid]?.clean()
                if chunk(eid) == nil {
                    map[eid] = Chunk()
                }
            }
            
            map.forEach { (key: EID, value: CoreParser.Chunk) in
                value.feed(event)
            }
        }
    }
}

extension CoreParser {
    class Chunk {
        public private(set) var events: [Event] = []
        
        public fileprivate(set) var tpMap: IInstruments.CoreProfileSessionTap.KDThreadMap? = nil
        public fileprivate(set) var occasion: HandleO = .undefined
        
        public var fCode: Event.FCode? {
            return events.first?.fCode
        }
        
        fileprivate func clean() {
            events = []
        }
        
        fileprivate func feed(_ event: Event) {
            events.append(event)
        }
    }
    
    struct Event {
        let body: IInstruments.CoreProfileSessionTap.KDEBUGElement
        let name: String?
        let timestamp: CGFloat
        
        var fCode: FCode { return FCode(rawValue: body.func_code)! }
        
        enum FCode: UInt32 {
            case start = 1
            case end = 2
            case all = 3
            case none = 0
        }
    }
}
