//
//  ITableView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit
import SwiftUI

extension IPerformanceView {
    struct ICharts: NSViewRepresentable {
        @EnvironmentObject var group: CPerformance.Chart.Group
        
        func makeNSView(context: Context) -> IPerformanceView.NSICharts {
            let nsView = IPerformanceView.NSICharts()
            setup(nsView)
            return nsView
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSICharts, context: Context) {
            setup(nsView)
        }
        
        private func setup(_ nsView: IPerformanceView.NSICharts) {
            nsView.target = self
            nsView.scrollView.offsetXState = group.highlighter.offsetXState
            nsView.scrollView.offsetX = group.highlighter.offsetX
            nsView.scrollView.hint = group.highlighter.hint
            nsView.refresh()
        }
    }
}

extension IPerformanceView {
    class NSICharts: NSView {
        fileprivate var target: IPerformanceView.ICharts? = nil
        
        fileprivate lazy var scrollView: ScrollView = {
            let scrollView = ScrollView()
            scrollView.scrollerStyle = .overlay
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = true
            scrollView.scrollerKnobStyle = .dark
            scrollView.horizontalScrollElasticity = .automatic
            scrollView.verticalScrollElasticity = .automatic
            return scrollView
        }()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            scrollView.target = self
            addSubview(scrollView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            scrollView.frame = bounds
            scrollView.backgroundColor = Color.P.BG1.NS
            refresh()
        }
        
        fileprivate func refresh() {
            scrollView.refresh()
        }
    }
}

fileprivate extension IPerformanceView.NSICharts {
    class ScrollView: NSScrollView {
        fileprivate weak var target: IPerformanceView.NSICharts? = nil
        
        private var view = NSView()
        private var cells: [IPerformanceView.ICharts.Cell] = []
        private var currentScrollIsHorizontal = false
        
        fileprivate var offsetX: CGFloat = 0
        fileprivate var offsetXState: S = .latest
        fileprivate var hint = Hint()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            documentView = view
            
            let tap = NSClickGestureRecognizer(target: self, action: #selector(click(_:)))
            addGestureRecognizer(tap)
            
            let drag = NSPanGestureRecognizer(target: self, action: #selector(drag(_:)))
            addGestureRecognizer(drag)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func refresh() {
            guard let group = target?.target?.group else {
                return
            }
            
            reload(group.notifiers)
        }
                
        private func reload(_ datas: [CPerformance.Chart.Notifier]) {
            let isNeedScrollTop = cells.count == 0
            
            if datas.count > cells.count {
                let padding = datas.count - cells.count
                (0 ..< padding).forEach { _ in
                    let cell = IPerformanceView.ICharts.Cell()
                    cell.frame.size = .init(width: bounds.width, height: 200)
                    cells.append(cell)
                    view.addSubview(cell)
                }
            }
            
            let padding: CGFloat = 10
            var y: CGFloat = 10
            
            calculate(0)
                        
            (0 ..< cells.count).forEach { index in
                let i = cells.count - index - 1
                let cell = cells[i]
                let notifier = datas[i]
                cell.reload(notifier, hint, offsetX)
                cell.isHidden = !notifier.graph.visible
                guard notifier.graph.visible else {
                    return
                }
                cell.frame = CGRect(x: 0, y: y, width: bounds.width, height: 230)
                y = cell.frame.maxY + padding
            }
            
            view.frame.size = CGSize(width: bounds.size.width, height: y)
            
            if isNeedScrollTop {
                scrollToTop()
            }
        }
        
        private func hintRender() {
            target?.target?.group.highlighter.hint = hint
            cells.forEach { cell in
                cell.hint(hint)
            }
        }
        
        // MARK: - calculate function
        
        override func scrollWheel(with event: NSEvent) {
            if event.phase == .began {
                currentScrollIsHorizontal = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY)
            }

            if currentScrollIsHorizontal {
                calculate(event.scrollingDeltaX)
                cells.forEach { cell in
                    cell.visible(canVisible(cell.convert(cell.bounds, to: self)))
                    cell.scroll(offsetX)
                }
                return
            }
            
            super.scrollWheel(with: event)
            cells.forEach { cell in
                cell.visible(canVisible(cell.convert(cell.bounds, to: self)))
            }
        }
        
        @objc private func click(_ gesture: NSClickGestureRecognizer) {
            if hint.action != .none {
                hint.action = .none
                hint.area.size.width = 0
            } else {
                hint.action = .click
                hint.area.origin = gesture.location(in: self)
                hint.offsetX = offsetX
            }
            hintRender()
        }
        
        @objc private func drag(_ gesture: NSPanGestureRecognizer) {
            if gesture.state == .began {
                hint.action = .drag
                hint.area.origin = gesture.location(in: self)
                hint.area.size.width = 0
                hint.offsetX = offsetX
            } else {
                hint.area.size.width = gesture.location(in: self).x - hint.area.origin.x
            }
            hintRender()
        }
                
        private func canVisible(_ frame: CGRect) -> Bool {
            if frame.maxY < -frame.height || frame.minY > self.frame.height + frame.height {
                return false
            }
            return true
        }
        
        private func calculate(_ deltaX: CGFloat) {
            var offsetX = self.offsetX
            guard let group = target?.target?.group else {
                return
            }
            
            offsetX += deltaX
            
            let w = frame.width - group.inset.left - group.inset.right
            let contentWidth: CGFloat = group.width * CGFloat(group.snapCount)
            
            let max: CGFloat = 0
            var min = w - contentWidth
            if min > 0 { min = 0 }
            
            if offsetXState == .stable {
                if offsetX < min {
                    offsetXState = .latest
                }
            } else {
                if deltaX > 0 {
                    offsetXState = .stable
                }
            }
            
            if offsetXState == .latest {
                offsetX = min
            }
            
            if offsetX > max { offsetX = max }
            else if offsetX < min { offsetX = min }
            
            self.offsetX = offsetX
            self.target?.target?.group.highlighter.offsetX = offsetX
            self.target?.target?.group.highlighter.offsetXState = offsetXState
        }
    }
}

extension IPerformanceView.NSICharts {
    enum Action {
        case none
        case click
        case drag
    }
    
    struct Hint {
        var offsetX: CGFloat = 0
        var action: Action = .none
        var area: CGRect = .zero
        #if DEBUG
        var description: String {
            """
            [action : \(action)]
            [X : \(area.origin.x)]
            [W : \(area.size.width)]
            """
        }
        #endif
    }
}

extension IPerformanceView.NSICharts {
    enum S {
        case latest
        case stable
    }
}

fileprivate extension NSScrollView {
    func scrollToTop() {
        if let documentView = self.documentView {
            if documentView.isFlipped {
                documentView.scroll(.zero)
            } else {
                let maxHeight = max(bounds.height, documentView.bounds.height)
                documentView.scroll(NSPoint(x: 0, y: maxHeight))
            }
        }
    }
}
