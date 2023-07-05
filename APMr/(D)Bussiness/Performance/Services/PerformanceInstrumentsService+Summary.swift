//
//  HomepageInstrumentsService+Summary.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/10.
//

import Foundation

extension PerformanceInstrumentsService {
    public enum HighlightState {
        case show(Int, Int)
        case none
        
        var start: Int {
            switch self {
                case .none:
                    return -1
                case .show(let x, _):
                    return x
            }
        }
        
        
        var end: Int {
            switch self {
                case .none:
                    return -1
                case .show(_, let x):
                    return x
            }
        }
    }
}

extension PerformanceInstrumentsService {
    class Summary: NSObject, ObservableObject {
        @Published private(set) var highlightState: HighlightState = .none
        
        public var highlightDatas: [SummaryItem] {
            guard highlightState.start >= 0,
                  highlightState.end >= 0,
                  highlightState.start < model.items.count,
                  highlightState.end < model.items.count else {
                return []
            }
            
            var start = highlightState.start
            var end = highlightState.end
            
            if start > end {
                start = highlightState.end
                end = highlightState.start
            }
            
            return Array(model.items[start ... end])
        }
        
        private var model = SummaryModel()
        private var temState: HighlightState = .none
        private var timer: Timer?
        
        deinit {
            stop()
        }
        
        public func set(startX: Int, endX: Int) {
            temState = .show(startX, endX)
            if timer == nil {
                start()
            }
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(stop), object: nil)
            perform(#selector(stop), with: nil, afterDelay: 0.5)
        }
        
        public func add(_ i: PerformanceIndicator) {            
            let infos = i.indicators.compactMap { indicator in
                let values = indicator.values.compactMap { value in
                    return SummaryItemValue(name: value.name, value: value.value, unit: value.unit)
                }
                let info = SummaryItemInfo()
                info.title = indicator.type.name
                info.values = values
                return info
            }
            let item = SummaryItem(time: i.recordSecond.intValue, values: infos)
            model.items.append(item)
        }
        
        public func reset() {
            highlightState = .none
            temState = .none
            model.items = []
        }
        
        @objc
        private func stop() {
            timer?.invalidate()
            timer = nil
        }
        
        private func start() {
            stop()
            
            let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
                if let state = self?.temState,
                   let current = self?.highlightState {
                    if state.start == current.start, state.end == current.end {
                        return
                    }
                    self?.highlightState = state
                }
            }
            timer.fire()
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
    }
}
