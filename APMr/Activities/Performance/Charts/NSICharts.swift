//
//  NSICharts.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/14.
//

import AppKit

extension IPerformanceView {
    class NSICharts: NSView {
        var target: IPerformanceView.ICharts? = nil
        
        fileprivate lazy var scrollView: ScrollView = {
            let scrollView = ScrollView()
            scrollView.scrollerStyle = .overlay
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = true
            scrollView.scrollerKnobStyle = .default
            scrollView.scrollerStyle = .overlay
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
            scrollView.backgroundColor = .box.BG1
            refresh()
        }
        
        func refresh() {
            scrollView.refresh()
        }
    }
}


fileprivate extension IPerformanceView.NSICharts {
    class ScrollView: NSScrollView {
        fileprivate weak var target: IPerformanceView.NSICharts? = nil
        
        fileprivate var actor: CPerformance.Chart.Actor? {
            return target?.target?.actor
        }
        
        fileprivate var group: CPerformance.Chart.Drawer.Group? {
            return target?.target?.group
        }
        
        private var view = NSView()
        private var cells: [IPerformanceView.ICharts.Cell] = []
        private var currentScrollIsHorizontal = false
        
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
        
        fileprivate func refresh() {
            guard let group, let actor else {
                return
            }
            
            let datas = group.notifiers
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
                  
            horizontal(0)
            
            (0 ..< cells.count).forEach { index in
                let i = cells.count - index - 1
                let cell = cells[i]
                let notifier = datas[i]
                cell.bind(notifier, actor)
                cell.isHidden = notifier.graph.visible.counter
                guard notifier.graph.visible else {
                    return
                }
                cell.frame = CGRect(x: 0, y: y, width: bounds.width, height: 230)
                y = cell.frame.maxY + padding
            }
            
            view.frame.size = CGSize(width: bounds.size.width, height: y)
            
            if isNeedScrollTop {
                documentView?.scroll(NSPoint(x: 0, y: y))
            }
        }
                        
        private func render() {
            cells.forEach { cell in
                cell.reload()
            }
        }
        
        // MARK: - calculate function
        
        override func scrollWheel(with event: NSEvent) {
            func visible(_ frame: CGRect) -> Bool {
                if frame.maxY < -frame.height || frame.minY > self.frame.height + frame.height {
                    return false
                }
                return true
            }
            
            if event.phase == .began {
                currentScrollIsHorizontal = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY)
            }

            if currentScrollIsHorizontal {
                horizontal(event.scrollingDeltaX)
                cells.forEach { cell in
                    cell.visible(visible(cell.convert(cell.bounds, to: self)))
                    cell.reload()
                }
                return
            }
            
            super.scrollWheel(with: event)
            cells.forEach { cell in
                cell.visible(visible(cell.convert(cell.bounds, to: self)))
                cell.reload()
            }
        }
        
        @objc private func click(_ gesture: NSClickGestureRecognizer) {
            typealias H = CPerformance.Chart.Actor.Highlighter.Hint

            guard let actor else { return }
            
            actor.hilighter.update(gesture.state == .began ? .click : .none)
            actor.hilighter.sync { hint in
                var hint = hint
                if hint.action != .none {
                    hint = H()
                } else {
                    let config = H.C(offset: actor.displayer.mutate.offsetX,
                                     location: gesture.location(in: self))
                    hint.action = .click
                    hint.begin = config
                    hint.end = config
                }
                return hint
            }
            
            render()
        }
        
        @objc private func drag(_ gesture: NSPanGestureRecognizer) {
            typealias H = CPerformance.Chart.Actor.Highlighter.Hint
            guard let actor else { return }
                        
            var current: H.C {
                H.C(offset: actor.displayer.mutate.offsetX,
                    location: gesture.location(in: self))
            }
            actor.hilighter.update(gesture.state == .ended ? .none : .drag)
            actor.hilighter.sync { hint in
                var hint = actor.hilighter.hint
                if gesture.state == .began {
                    hint.action = .drag
                    hint.end = nil
                    hint.begin = current
                } else {
                    hint.end = current
                }
                return hint
            }
            
            render()
        }
                
        private func horizontal(_ deltaX: CGFloat) {
            guard let group ,let actor else { return }
            
            let w = frame.width - group.inset.left - group.inset.right
            let contentWidth: CGFloat = group.width * CGFloat(group.snapCount)
            let max: CGFloat = 0
            var min = w - contentWidth
            if min > 0 { min = 0 }
            
            actor.displayer.sync { mutate in
                var mutate = mutate
                var offset = mutate.offsetX
                var state = mutate.state
                
                offset += deltaX
                
                if state == .stable {
                    if offset < min {
                        state = .latest
                    }
                } else {
                    if deltaX > 0 {
                        state = .stable
                    }
                }
                
                if state == .latest {
                    offset = min
                }
                
                if offset > max { offset = max }
                else if offset < min { offset = min }
                mutate.offsetX = offset
                mutate.state = state
                return mutate
            }
            
            guard actor.hilighter.current == .drag, let end = actor.hilighter.hint.end else { return }
            actor.hilighter.sync { hint in
                var hint = actor.hilighter.hint
                hint.end = .init(offset: actor.displayer.mutate.offsetX,
                                  location: end.location)
                return hint
            }
        }
    }
}
