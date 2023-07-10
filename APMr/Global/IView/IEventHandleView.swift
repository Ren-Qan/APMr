//
//  IEventHandleView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

struct IEventHandleView: NSViewRepresentable {
    fileprivate var monitor: ((IEvent) -> Void)? = nil
    
    func makeNSView(context: Context) -> INSEventHandleView {
        let view = INSEventHandleView()
        view.target = self
        return view
    }
    
    func updateNSView(_ nsView: INSEventHandleView, context: Context) {
        nsView.target = self
    }
    
    func onEvent(_ closure: @escaping (_ iEvent: IEvent) -> Void) -> Self {
        var e = self
        e.monitor = closure
        return e
    }
}

extension IEventHandleView {
    struct IEvent {
        let source: NSEvent
        let locationInView: CGPoint
        
        init(source: NSEvent, locationInView: CGPoint) {
            self.source = source
            self.locationInView = locationInView
        }
    }
}

class INSEventHandleView: NSView {
    fileprivate var target: IEventHandleView? = nil
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        ScrollEventHandle.share.monitor = { event in
            self.make(event)
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        trackingAreas.forEach { area in
            removeTrackingArea(area)
        }
        
        let tracking = NSTrackingArea(rect: self.bounds,
                                      options: [.mouseMoved,
                                                .mouseEnteredAndExited,
                                                .activeInActiveApp,
                                                .inVisibleRect,
                                                .assumeInside,
                                                .cursorUpdate],
                                      owner: self)
        addTrackingArea(tracking)
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        make(event)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        make(event)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        make(event)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        make(event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        make(event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        super.rightMouseDragged(with: event)
        make(event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        make(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        make(event)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        make(event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseEntered(with: event)
        make(event)
    }
    
    private func make(_ event: NSEvent) {
        let location = self.convert(event.locationInWindow, from: nil)
        let iEvent = IEventHandleView.IEvent(source: event, locationInView: location)
        target?.monitor?(iEvent)
    }
}

extension INSEventHandleView {
    fileprivate class ScrollEventHandle {
        static var share = ScrollEventHandle()
        
        var monitor: ((NSEvent) -> Void)? = nil
        
        init() {
            NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                ScrollEventHandle.share.monitor?(event)
                return event
            }
        }
    }
}

