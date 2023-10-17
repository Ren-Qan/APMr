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
        
        fileprivate static var inset = NSEdgeInsets(top: 25, left: 20, bottom: 20, right: 0)
        fileprivate static var width: CGFloat = 20
    
        public func clean() {
            group.reset()
        }
        
        public func preset(_ model: DSPMetrics.M) {
            model.all.forEach { target in
                if self.map[target.type] == nil {
                    let notifier = Notifier(type: target.type)
                    self.group.notifiers.append(notifier)
                    self.map[target.type] = notifier
                }
            }
        }
                
        public func sync(_ model: DSPMetrics.M) {
            struct M {
                let type: DSPMetrics.T
                let marks: [Mark]
                
                init(_ type: DSPMetrics.T,
                     _ marks: [Mark]) {
                    self.type = type
                    self.marks = marks
                }
            }
                        
            let cpu = M(.CPU,
                        [Mark(model.cpu.total, "Total"),
                         Mark(model.cpu.process, "Process")])
            
            let gpu = M(.GPU,
                        [Mark(model.gpu.device, "Device"),
                         Mark(model.gpu.tiler, "Tiler"),
                         Mark(model.gpu.renderer, "Renderer")])
            
            let fps = M(.FPS, [Mark(model.fps.fps, "FPS")])
            
            let memory = M(.Memory, [Mark(model.memory.memory, "Memory"),
                                     Mark(model.memory.resident, "Resident"),
                                     Mark(model.memory.vm, "VM")])
            
            let io = M(.IO, [Mark(model.io.write, "Write"),
                             Mark(model.io.read, "Read"),
                             Mark(model.io.writeDelta, "WriteDelta"),
                             Mark(model.io.readDelta, "ReadDelta")])
            
            let network = M(.Network, [Mark(model.network.down, "Down"),
                                       Mark(model.network.up, "Up"),
                                       Mark(model.network.downDelta, "DownDelta"),
                                       Mark(model.network.upDelta, "UpDelta")])
            
            let diagnostic = M(.Diagnostic, [Mark(model.diagnostic.amperage, "Amperage"),
                                             Mark(model.diagnostic.battery, "Battery"),
                                             Mark(model.diagnostic.temperature, "Temperature"),
                                             Mark(model.diagnostic.voltage, "Voltage")])
            
            
            [cpu, gpu, fps, memory, io, network, diagnostic].forEach { m in
                self.map[m.type]?.graph.update(m.marks)
            }
            self.group.sync()
        }
    }
}

extension CPerformance.Chart {
    class Group: ObservableObject {
        public var inset: NSEdgeInsets { CPerformance.Chart.inset }
        public var width: CGFloat { CPerformance.Chart.width }
        
        fileprivate(set) var snapCount: Int = 0
        fileprivate(set) var notifiers: [Notifier] = []
        fileprivate(set) var highlighter = Highlighter()
                     
        fileprivate func reset() {
            snapCount = 0
            highlighter.reset()
            notifiers.forEach { notifier in
                notifier.graph.clean()
            }
        }
        
        fileprivate func sync() {
            self.snapCount += 1
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
        
        public var inset: NSEdgeInsets { CPerformance.Chart.inset }
        
        fileprivate func clean() {
            axis.clean()
            series.forEach { s in
                s.clean()
            }
        }
        
        fileprivate func update(_ sources: [CPerformance.Chart.Mark]) {
            if series.count != sources.count {
                series.removeAll()
                
                sources.each { index, _ in
                    let item = Series()
                    series.append(item)
                    return true
                }
            }
             
            axis.update(sources)
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
        
        public var width: CGFloat { CPerformance.Chart.width }
        
        fileprivate func clean() {
            upper = nil
            count = 0
        }
        
        fileprivate func update(_ sources: [CPerformance.Chart.Mark]) {
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
