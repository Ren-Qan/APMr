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
        fileprivate(set) static var inset = NSEdgeInsets(top: 25, left: 20, bottom: 20, right: 0)
        fileprivate(set) static var width: CGFloat = 20
        
        private(set) var actor = Actor()
        private(set) var group = Drawer.Group()
        
        private var map: [DSPMetrics.T : Drawer.Notifier] = [:]
            
        public func clean() {
            actor.reset()
            group.reset()
        }
        
        public func preset(_ model: DSPMetrics.M) {
            model.all.forEach { target in
                if self.map[target.type] == nil {
                    let notifier = Drawer.Notifier(type: target.type)
                    self.group.add(notifier)
                    self.map[target.type] = notifier
                }
            }
        }
                
        public func sync(_ model: DSPMetrics.M,
                         _ timing: TimeInterval) {
            struct M {
                let type: DSPMetrics.T
                let marks: [Mark]
                
                init(_ type: DSPMetrics.T,
                     _ marks: [Mark]) {
                    self.type = type
                    self.marks = marks
                }
            }
                        
            let cpu = M(.CPU, [Mark(timing, model.cpu.total, "Total"),
                         Mark(timing, model.cpu.process, "Process")])
            
            let gpu = M(.GPU, [Mark(timing, model.gpu.device, "Device"),
                         Mark(timing, model.gpu.tiler, "Tiler"),
                         Mark(timing, model.gpu.renderer, "Renderer")])
            
            let fps = M(.FPS, [Mark(timing, model.fps.fps, "FPS")])
            
            let memory = M(.Memory, [Mark(timing, model.memory.memory, "Memory"),
                                     Mark(timing, model.memory.resident, "Resident"),
                                     Mark(timing, model.memory.vm, "VM")])
            
            let io = M(.IO, [Mark(timing, model.io.write, "Write"),
                             Mark(timing, model.io.read, "Read"),
                             Mark(timing, model.io.writeDelta, "WriteDelta"),
                             Mark(timing, model.io.readDelta, "ReadDelta")])
            
            let network = M(.Network, [Mark(timing, model.network.down, "Down"),
                                       Mark(timing, model.network.up, "Up"),
                                       Mark(timing, model.network.downDelta, "DownDelta"),
                                       Mark(timing, model.network.upDelta, "UpDelta")])
            
            let diagnostic = M(.Diagnostic, [Mark(timing, model.diagnostic.amperage, "Amperage"),
                                             Mark(timing, model.diagnostic.battery, "Battery"),
                                             Mark(timing, model.diagnostic.temperature, "Temperature"),
                                             Mark(timing, model.diagnostic.voltage, "Voltage")])
            
            
            [cpu, gpu, fps, memory, io, network, diagnostic].forEach { m in
                self.map[m.type]?.graph.update(m.marks)
            }
            
            self.group.sync()
            self.actor.hilighter.snap.match(Self.width, Self.inset, self.group.snapCount)
        }
    }
}


#if DEBUG
extension CPerformance.Chart {
    static var debug_Data = DSPMetrics.M()
    public func addRandom(_ timming: TimeInterval) {
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
        
        sync(CPerformance.Chart.debug_Data, timming)
    }
}
#endif
