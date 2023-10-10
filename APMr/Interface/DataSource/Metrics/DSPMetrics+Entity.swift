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
        
        var text: String { "\(self)" }
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
    enum U {
        case Percent
        case MB
        case GB
        case Frame
        case mA
        case V
        case Celsius
        
        var format: String {
            switch self {
                case .Percent:
                    return "%"
                case .MB:
                    return "MB"
                case .GB:
                    return "GB"
                case .Frame:
                    return "F"
                case .mA:
                    return "mA"
                case .V:
                    return "V"
                case .Celsius:
                    return "°C"
            }
        }
    }
    
    struct R {
        var value: CGFloat = 0
        let unit: U
        
        init(_ unit: U) {
            self.unit = unit
        }
        
        mutating func set(_ value: CGFloat) {
            self.value = value
        }
    }
}

extension DSPMetrics.M {
    class CPU: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .CPU }
        
        var total = R(.Percent)      // 0 - 100
        var process = R(.Percent)   // 0 - 100
        
        func reset() {
            total.value = 0
            process.value = 0
        }
    }
    
    class GPU: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .GPU }
        
        var device = R(.Percent)    // 0 - 100
        var renderer = R(.Percent)// 0 - 100
        var tiler = R(.Percent)    // 0 - 100
        
        func reset() {
            device.value = 0
            renderer.value = 0
            tiler.value = 0
        }
    }
    
    class FPS: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .FPS }
        
        var fps = R(.Frame)
        var jank = R(.Frame)
        var bigJank = R(.Frame)
        var stutter = R(.Frame)
        
        func reset() {
            fps.value = 0
            jank.value = 0
            bigJank.value = 0
            stutter.value = 0
        }
    }
    
    class Network: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Network }
        
        var down = R(.MB)
        var up = R(.MB)
        var downDelta = R(.MB) // MB
        var upDelta = R(.MB) // MB
        
        func reset() {
            down.value = 0
            up.value = 0
            downDelta.value = 0
            upDelta.value = 0
        }
    }
    
    class Memory: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Memory }
        
        var resident = R(.MB) // MB
        var memory = R(.MB) // MB
        var vm = R(.GB) // GB
        
        func reset() {
            resident.value = 0
            memory.value = 0
            vm.value = 0
        }
    }
    
    class IO: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .IO }
        
        var read = R(.MB) // MB
        var write = R(.MB)// MB
        var readDelta = R(.MB) // MB
        var writeDelta = R(.MB) // MB
        
        func reset() {
            read.value = 0
            write.value = 0
            readDelta.value = 0
            writeDelta.value = 0
        }
    }
    
    class Diagnostic: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Diagnostic }
        
        var amperage = R(.mA) // mA
        var voltage = R(.V) // V
        var battery = R(.Percent) // 1 - 100
        var temperature = R(.Celsius) // °C
        
        func reset() {
            amperage.value = 0
            voltage.value = 0
            battery.value = 0
            temperature.value = 0
        }
    }
}
