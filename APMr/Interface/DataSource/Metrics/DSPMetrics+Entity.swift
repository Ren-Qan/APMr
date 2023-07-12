//
//  DSPMetrics+Entity.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/12.
//

import AppKit

extension DSPMetrics {
    enum MT {
        case app(IApp)
        case pid(PID)
        case empty
    }
    
    enum MR {
        case pid(PID)
        case empty
    }
    
    struct Monitor {
        var type: MT = .empty
        var result: MR = .empty
    }
}

extension DSPMetrics {
    enum T {
        case CPU
        case GPU
        case FPS
        case Network
        case Memory
        case IO
        case Diagnostic
    }
    
    enum S {
        case invalid
        case success(M)
    }
    
    struct M {
        let cpu = CPU()
        let gpu = GPU()
        let fps = FPS()
        let network = Network()
        let memory = Memory()
        let io = IO()
        let diagnostic = Diagnostic()

        var all: [DSPMetricsMItemProtocol] {
            [cpu, gpu, fps, network, memory, io, diagnostic]
        }
                
        func reset() {
            all.forEach { item in
                item.reset()
            }
        }
    }
}

protocol DSPMetricsMItemProtocol {
    var type: DSPMetrics.T { get }
    func reset()
}

extension DSPMetrics.M {
    class CPU: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .CPU }
        
        var total: CGFloat = 0      // 0 - 100
        var process: CGFloat = 0    // 0 - 100
        
        func reset() {
            total = 0
            process = 0
        }
    }
    
    class GPU: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .GPU }
        
        var device: CGFloat = 0     // 0 - 100
        var renderer: CGFloat = 0   // 0 - 100
        var tiler: CGFloat = 0      // 0 - 100
        
        func reset() {
            device = 0
            renderer = 0
            tiler = 0
        }
    }
    
    class FPS: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .FPS }
        
        var fps: CGFloat = 0
        var jank: CGFloat = 0
        var bigJank: CGFloat = 0
        var stutter: CGFloat = 0
        
        func reset() {
            fps = 0
            jank = 0
            bigJank = 0
            stutter = 0
        }
    }
    
    class Network: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Network }
        
        var down: CGFloat = 0
        var up: CGFloat = 0
        var downDelta: CGFloat = 0 // MB
        var upDelta: CGFloat = 0 // MB
        
        func reset() {
            down = 0
            up = 0
            downDelta = 0
            upDelta = 0
        }
    }
    
    class Memory: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Memory }
        
        var resident: CGFloat = 0 // MB
        var memory: CGFloat = 0 // MB
        var vm: CGFloat = 0 // GB
        
        func reset() {
            resident = 0
            memory = 0
            vm = 0
        }
    }
    
    class IO: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .IO }
        
        var read: CGFloat = 0 // MB
        var write: CGFloat = 0 // MB
        var readDelta: CGFloat = 0 // MB
        var writeDelta: CGFloat = 0 // MB
        
        func reset() {
            read = 0
            write = 0
            readDelta = 0
            writeDelta = 0
        }
    }
    
    class Diagnostic: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Diagnostic }
        
        var amperage: CGFloat = 0 // mA
        var voltage: CGFloat = 0 // V
        var battery: CGFloat = 0 // 1 - 100
        var temperature: CGFloat = 0 // °C
        
        func reset() {
            amperage = 0
            voltage = 0
            battery = 0
            temperature = 0
        }
    }
}
