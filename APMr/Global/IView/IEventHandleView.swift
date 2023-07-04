//
//  IEventHandleView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

struct IEventHandleView: NSViewRepresentable {
    fileprivate var monitor: ((NSEvent) -> Void)? = nil
    
    func makeNSView(context: Context) -> INSEventHandleView {
        let view = INSEventHandleView()
        view.target = self
        return view
    }
    
    func updateNSView(_ nsView: INSEventHandleView, context: Context) {
   
    }
    
    func onEvent(_ closure: @escaping (NSEvent) -> Void) -> Self {
        var e = self
        e.monitor = closure
        return e
    }
}

class INSEventHandleView: NSView {
    fileprivate var target: IEventHandleView? = nil
    
    override var acceptsFirstResponder: Bool {
        return true
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
        target?.monitor?(event)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        target?.monitor?(event)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        target?.monitor?(event)
    }
    
    override func rightMouseUp(with event: NSEvent) {
        super.rightMouseUp(with: event)
        target?.monitor?(event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        target?.monitor?(event)
    }
    
    override func rightMouseDragged(with event: NSEvent) {
        super.rightMouseDragged(with: event)
        target?.monitor?(event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        target?.monitor?(event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        target?.monitor?(event)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        target?.monitor?(event)
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        target?.monitor?(event)
    }
}
