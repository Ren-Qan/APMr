//
//  ITableView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit
import SwiftUI

extension IPerformanceView {
    struct ITableView: NSViewRepresentable {
        @EnvironmentObject var group: CPerformance.Chart.Group
        
        func makeNSView(context: Context) -> IPerformanceView.NSITableView {
            let view = IPerformanceView.NSITableView()
            view.target = self
            view.refresh()
            return view
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSITableView, context: Context) {
            nsView.target = self
            nsView.refresh()
        }
    }
}

extension IPerformanceView {
    class NSITableView: NSView {
        fileprivate var target: IPerformanceView.ITableView? = nil
        
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
            addSubview(scrollView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            scrollView.frame = bounds
            refresh()
        }
        
        fileprivate func refresh() {
            if let datas = target?.group.notifiers {
                scrollView.update(datas)
            }
        }
    }
}

fileprivate extension IPerformanceView.NSITableView {
    class ScrollView: NSScrollView {
        private var cells: [IPerformanceView.ITableView.Cell] = []
        private var view = NSView()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            documentView = view
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(_ datas: [CPerformance.Chart.Notifier]) {
            check(datas)
        }
        
        private func check(_ datas: [CPerformance.Chart.Notifier]) {
            let isNeedScrollTop = cells.count == 0
            
            if datas.count > cells.count {
                let padding = datas.count - cells.count
                (0 ..< padding).forEach { _ in
                    let cell = IPerformanceView.ITableView.Cell()
                    cell.frame.size = .init(width: bounds.width, height: 200)
                    cells.append(cell)
                    view.addSubview(cell)
                }
            }
            
            let padding: CGFloat = 10
            var y: CGFloat = 10
            (0 ..< cells.count).forEach { index in
                let i = cells.count - index - 1
                let cell = cells[i]
                let notifier = datas[i]
                cell.reload(notifier)
                cell.isHidden = !notifier.graph.visible
                guard notifier.graph.visible else {
                    return
                }
                cell.frame = CGRect(x: 0, y: y, width: bounds.width, height: 200)
                y = cell.frame.maxY + padding
            }
            
            view.frame.size = CGSize(width: bounds.size.width, height: y)
            
            if isNeedScrollTop {
                scrollToTop()
            }
        }
        
        override func scrollWheel(with event: NSEvent) {
            super.scrollWheel(with: event)
        }
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
