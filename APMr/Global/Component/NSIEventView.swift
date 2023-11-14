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
    private lazy var mouseOperationMap: [MouseOperation : Closue] = [:]
    
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
                                                 .mouseMoved],
                                       owner: self)
            addTrackingArea(track)
            self.trackArea = track
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        mouseOperationMap[.entered]?(self)
    }

    override func mouseExited(with event: NSEvent) {
        mouseOperationMap[.existed]?(self)

    }
    
    override func mouseMoved(with event: NSEvent) {
        mouseOperationMap[.moved]?(self)
    }
    
    override func mouseDown(with event: NSEvent) {
        mouseOperationMap[.down]?(self)
    }
    
    override func mouseUp(with event: NSEvent) {
        if event.clickCount == 1 {
            mouseOperationMap[.click]?(self)
        }
        mouseOperationMap[.up]?(self)
    }
}

extension NSIEventView {
    @objc fileprivate func click(_ sender: NSIEventView) {
        mouseOperationMap[.click]?(self)
    }
}

extension NSIEventView {
    typealias Closue = (_ button: NSIEventView) -> Void
    
    enum MouseOperation {
        case click
        case entered
        case existed
        case moved
        case down
        case up
    }
    
    @discardableResult
    public func mouse(_ operation: MouseOperation,
                      _ closure: @escaping Closue) -> Self {
        switch operation {
            case .existed, .entered, .moved: self.isNeedTrackEvent = true
            default: break
        }
        mouseOperationMap[operation] = closure
        return self
    }
}
