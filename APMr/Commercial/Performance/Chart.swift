//
//  Chart.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine
import SwiftUI

extension CPerformance {
    class Chart {
        private(set) var group = Group()
        
        private var map: [DSPMetrics.T : Notifier] = [:]
        private var inset = NSEdgeInsets(top: 25, left: 20, bottom: 20, right: 0)
        private var width: CGFloat = 20
    
        public func preset(_ model: DSPMetrics.M) {
            model.all.forEach { i in
                if self.map[i.type] == nil {
                    let notifier = Notifier(type: i.type)
                    notifier.graph.inset = inset
                    notifier.graph.axis.width = width
                    self.group.notifiers.append(notifier)
                    self.map[i.type] = notifier
                }
            }
            group.inset = inset
            group.width = width
        }
        
        public func clean() {
            group.reset()
            group.notifiers.forEach { notifier in
                notifier.graph.clean()
            }
        }
        
        public func sync(_ model: DSPMetrics.M) {
            let cpu = [Mark(model.cpu.total, "Total"),
                       Mark(model.cpu.process, "Process")]
            
            let gpu = [Mark(model.gpu.device, "Device"),
                       Mark(model.gpu.tiler, "Tiler"),
                       Mark(model.gpu.renderer, "Renderer")]
            
            let fps = [Mark(model.fps.fps, "FPS")]
            
            let memory = [Mark(model.memory.memory, "Memory"),
                          Mark(model.memory.resident, "Resident"),
                          Mark(model.memory.vm, "VM")]
            
            let io = [Mark(model.io.write, "Write"),
                      Mark(model.io.read, "Read"),
                      Mark(model.io.writeDelta, "WriteDelta"),
                      Mark(model.io.readDelta, "ReadDelta")]
            
            let network = [Mark(model.network.down, "Down"),
                           Mark(model.network.up, "Up"),
                           Mark(model.network.downDelta, "DownDelta"),
                           Mark(model.network.upDelta, "UpDelta")]
            
            let diagnostic = [Mark(model.diagnostic.amperage, "Amperage"),
                              Mark(model.diagnostic.battery, "Battery"),
                              Mark(model.diagnostic.temperature, "Temperature"),
                              Mark(model.diagnostic.voltage, "Voltage")]
            
            update(.CPU, cpu)
            update(.GPU, gpu)
            update(.FPS, fps)
            update(.Memory, memory)
            update(.IO, io)
            update(.Network, network)
            update(.Diagnostic, diagnostic)
            
            group.sync(inset, width)
        }
    }
}

extension CPerformance.Chart {
    private func update(_ type: DSPMetrics.T,
                        _ sources: [CPerformance.Chart.Mark]) {
        guard let notifier = map[type] else {
            return
        }
                
        notifier.graph.inset = inset
        notifier.graph.update(width, sources)
    }
}

extension CPerformance.Chart {
    class Group: ObservableObject {
        fileprivate(set) var notifiers: [Notifier] = []
        // 只需要编辑 Chart 中的inset
        fileprivate(set) var inset = NSEdgeInsets(top: 10, left: 20, bottom: 20, right: 0)
        fileprivate(set) var width: CGFloat = 20
        
        fileprivate(set) var snapCount: Int = 0
        fileprivate(set) var highlighter = Highlighter()
                
        public func reset() {
            highlighter.reset()
            snapCount = 0
        }
        
        fileprivate func sync(_ inset: NSEdgeInsets,
                              _ width: CGFloat) {
            self.snapCount += 1
            self.inset = inset
            self.width = width
            self.highlighter.sync(inset, width, snapCount)
            self.objectWillChange.send()
        }
    }
    
    class Notifier: Identifiable, ObservableObject {
        public let type: DSPMetrics.T
        public let graph = Graph()
        
        init(type: DSPMetrics.T) {
            self.type = type
        }
    }
}

// Line
extension CPerformance.Chart.Notifier {
    class Graph {
        fileprivate(set) var axis = Axis()
        fileprivate(set) var series: [Series] = []
        fileprivate(set) var visible: Bool = true
        // 只需要编辑 Chart 中的inset
        fileprivate(set) var inset = NSEdgeInsets(top: 10, left: 20, bottom: 20, right: 0)
        
        fileprivate func clean() {
            axis.clean()
            series.forEach { s in
                s.clean()
            }
        }
        
        fileprivate func update(_ width: CGFloat,
                                _ sources: [CPerformance.Chart.Mark]) {
            if series.count != sources.count {
                series.removeAll()
                
                sources.each { index, _ in
                    let item = Series()
                    series.append(item)
                    return true
                }
            }
             
            axis.update(width, sources)
            (0 ..< sources.count).forEach { i in
                let series = series[i]
                let source = sources[i]
                series.update(source)
            }
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class Series: Identifiable {
        fileprivate(set) var marks: [CPerformance.Chart.Mark] = []
        fileprivate(set) var visible: Bool = true
                
        fileprivate func clean() {
            marks.removeAll()
        }
        
        fileprivate func update(_ source: CPerformance.Chart.Mark) {
            marks.append(source)
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class Axis {
        fileprivate(set) var upper: CPerformance.Chart.Mark? = nil
        fileprivate(set) var count = 0
        fileprivate(set) var width: CGFloat = 20
        
        fileprivate func clean() {
            upper = nil
            count = 0
        }
        
        fileprivate func update(_ width: CGFloat,
                                _ sources: [CPerformance.Chart.Mark]) {
            self.width = width
            self.count += 1
            
            let max = sources.max { l, r in
                return l.source.value < r.source.value
            }
            
            if (max?.source.value ?? 0) > (upper?.source.value ?? 0) {
                upper = max
            }
        }
    }
}



#if DEBUG
extension CPerformance.Chart {
    static var debug_Data = DSPMetrics.M()
    public func addRandom(_ count: Int) {
        (0 ..< count).forEach { _ in
            CPerformance.Chart.debug_Data.cpu.total.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.cpu.process.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.gpu.device.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.gpu.renderer.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.gpu.tiler.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.fps.fps.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.io.read.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.io.write.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.io.readDelta.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.io.writeDelta.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.network.up.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.network.down.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.network.upDelta.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.network.downDelta.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.memory.memory.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.memory.resident.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.memory.vm.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.diagnostic.amperage.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.diagnostic.battery.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.diagnostic.temperature.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.diagnostic.voltage.value = .random(in:  0.1 ... 99.9)
            
            sync(CPerformance.Chart.debug_Data)
        }
    }
}
#endif
