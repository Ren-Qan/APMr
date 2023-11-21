//
//  NSIButton.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/14.
//

import AppKit

class NSIEventView: NSView {
    public var isNeedTrackEvent = false {
        didSet {
            updateTrackingAreas()
        }
    }
    
    private var trackArea: NSTrackingArea? = nil
    private lazy var mouseOperationMap: [MouseOperation : Closure] = [:]
    private lazy var highlightClosure: HClosure? = nil
    private var highlightState = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackArea {
            removeTrackingArea(trackArea)
            self.trackArea = nil
        }
        
        if isNeedTrackEvent {
            let track = NSTrackingArea(rect: bounds,
                                       options: [.activeInActiveApp,
                                                 .mouseEnteredAndExited,
                                                 .mouseMoved,
                                                 .enabledDuringMouseDrag
                                            ],
                                       owner: self)
            addTrackingArea(track)
            self.trackArea = track
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseOperationMap[.entered]?(MEvent(view: self, event: event))
    }

    override func mouseExited(with event: NSEvent) {
        mouseOperationMap[.existed]?(MEvent(view: self, event: event))
        highlight(false, event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        mouseOperationMap[.moved]?(MEvent(view: self, event: event))
    }
    
    override func mouseDown(with event: NSEvent) {
        mouseOperationMap[.down]?(MEvent(view: self, event: event))
        highlight(true, event)
    }
        
    override func mouseUp(with event: NSEvent) {
        if event.clickCount == 1 {
            mouseOperationMap[.click]?(MEvent(view: self, event: event))
        }
        mouseOperationMap[.up]?(MEvent(view: self, event: event))
        highlight(false, event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        mouseOperationMap[.drag]?(MEvent(view: self, event: event))
        highlight(bounds.contains(convert(event.locationInWindow, from: nil)), event)
    }
}

extension NSIEventView {
    fileprivate func highlight(_ state: Bool, _ event: NSEvent) {
        if highlightState != state {
            highlightClosure?(HEvent(isHighligt: state, view: self, event: event))
        }
        
        highlightState = state
    }
}

extension NSIEventView {
    typealias Closure = (_ event: MEvent) -> Void
    typealias HClosure = (_ event: HEvent) -> Void
    
    struct HEvent {
        let isHighligt: Bool
        let view: NSIEventView
        let event: NSEvent
    }
    
    struct MEvent {
        let view: NSIEventView
        let event: NSEvent
    }
    
    enum MouseOperation {
        case click
        case entered
        case existed
        case moved
        case down
        case up
        case drag
    }
    
    @discardableResult
    public func mouse(_ operation: MouseOperation,
                      _ closure: @escaping Closure) -> Self {
        switch operation {
            case .existed, .entered, .moved: self.isNeedTrackEvent = true
            default: break
        }
        mouseOperationMap[operation] = closure
        return self
    }
    
    @discardableResult
    public func highlight(_ closure: @escaping HClosure) -> Self {
        self.isNeedTrackEvent = true
        self.highlightClosure = closure
        return self
    }
}
