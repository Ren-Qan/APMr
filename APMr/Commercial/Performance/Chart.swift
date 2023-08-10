//
//  Chart.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

extension CPerformance {
    class Chart {
        private(set) var group = Group()
        
        private var map: [DSPMetrics.T : Notifier] = [:]
        private var width: CGFloat = 20
    
        public func preset(_ model: DSPMetrics.M) {
            model.all.forEach { i in
                if self.map[i.type] == nil {
                    let notifier = Notifier(type: i.type)
                    self.group.notifiers.append(notifier)
                    self.map[i.type] = notifier
                }
            }
        }
        
        public func clean() {
            group.notifiers.forEach { notifier in
                notifier.graph.clean()
            }
        }
        
        public func sync(_ model: DSPMetrics.M) {
            let cpu =           [model.cpu.total, model.cpu.process]
            let gpu =           [model.gpu.device, model.gpu.tiler, model.gpu.renderer]
            let fps =           [model.fps.fps]
            let memory =        [model.memory.memory, model.memory.resident, model.memory.vm]
            let io =            [model.io.write, model.io.readDelta, model.io.writeDelta, model.io.readDelta]
            let network =       [model.network.down, model.network.up, model.network.downDelta, model.network.upDelta]
            let diagnostic =    [model.diagnostic.amperage, model.diagnostic.battery, model.diagnostic.temperature, model.diagnostic.voltage]
            
            update(.CPU, cpu)
            update(.GPU, gpu)
            update(.FPS, fps)
            update(.Memory, memory)
            update(.IO, io)
            update(.Network, network)
            update(.Diagnostic, diagnostic)
            group.objectWillChange.send()
        }
    }
}

extension CPerformance.Chart {
    private func update(_ type: DSPMetrics.T,
                        _ sources: [DSPMetrics.M.R]) {
        guard let notifier = map[type] else {
            return
        }
                
        notifier.graph.update(width, sources)
    }
}

extension CPerformance.Chart {
    class Group: ObservableObject {
        var notifiers: [Notifier] = []
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
        private(set) var axis = Axis()
        private(set) var series: [Series] = []
        private(set) var visible: Bool = true
        
        fileprivate func clean() {
            axis.clean()
            series.forEach { s in
                s.clean()
            }
        }
        
        fileprivate func update(_ width: CGFloat, _ sources: [DSPMetrics.M.R]) {
            if series.count != sources.count {
                series.removeAll()
                sources.forEach { _ in
                    let item = Series()
                    series.append(item)
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
        fileprivate var sources: [DSPMetrics.M.R] = []
        
        private(set) var visible: Bool = true
        private(set) var style: NSColor = .random
                
        fileprivate func clean() {
            sources.removeAll()
        }
        
        fileprivate func update(_ source: DSPMetrics.M.R) {
            sources.append(source)
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class Axis {
        fileprivate var style: NSColor = .black.withAlphaComponent(0.3)
        
        fileprivate func clean() {
            
        }
        
        fileprivate func update(_ width: CGFloat, _ sources: [DSPMetrics.M.R]) {
            
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
