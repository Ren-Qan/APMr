//
//  DSPMetrics.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import Foundation

class DSPMetrics: NSObject, ObservableObject {
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let sysmontap = IInstruments.Sysmontap()
        sysmontap.delegate = self
        
        let opengl = IInstruments.Opengl()
        opengl.delegate = self
        
        let process = IInstruments.Processcontrol()
        process.delegate = self
        
        let net = IInstruments.NetworkStatistics()
        net.delegate = self
                
        let group = IInstrumentsServiceGroup()
        group.config([sysmontap, opengl, process, net])
        
        return group
    }()
    
    private(set) lazy var syncModel = M()
}

extension DSPMetrics {
    public func reset() {
        syncModel.reset()
    }
}

extension DSPMetrics: IInstrumentsSysmontapDelegate {
    
}

extension DSPMetrics: IInstrumentsOpenglDelegate {
    
}

extension DSPMetrics: IInstrumentsProcesscontrolDelegate {
    
}

extension DSPMetrics: IInstrumentsNetworkStatisticsDelegate {
    
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
        
        fileprivate(set) var total: CGFloat = 0      // 0 - 100
        fileprivate(set) var process: CGFloat = 0    // 0 - 100
        
        func reset() {
            total = 0
            process = 0
        }
    }
    
    class GPU: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .GPU }
        
        fileprivate(set) var device: CGFloat = 0     // 0 - 100
        fileprivate(set) var renderer: CGFloat = 0   // 0 - 100
        fileprivate(set) var tiler: CGFloat = 0      // 0 - 100
        
        func reset() {
            device = 0
            renderer = 0
            tiler = 0
        }
    }
    
    class FPS: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .FPS }
        
        fileprivate(set) var fps: CGFloat = 0
        fileprivate(set) var jank: CGFloat = 0
        fileprivate(set) var bigJank: CGFloat = 0
        fileprivate(set) var stutter: CGFloat = 0
        
        func reset() {
            fps = 0
            jank = 0
            bigJank = 0
            stutter = 0
        }
    }
    
    class Network: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Network }
        
        fileprivate(set) var down: CGFloat = 0
        fileprivate(set) var up: CGFloat = 0
        fileprivate(set) var downDelta: CGFloat = 0 // MB/s
        fileprivate(set) var upDelta: CGFloat = 0 // MB/s
        
        func reset() {
            down = 0
            up = 0
            downDelta = 0
            upDelta = 0
        }
    }
    
    class Memory: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Memory }
        
        fileprivate(set) var resident: CGFloat = 0 // MB
        fileprivate(set) var memory: CGFloat = 0 // MB
        fileprivate(set) var vm: CGFloat = 0 // GB
        
        func reset() {
            resident = 0
            memory = 0
            vm = 0
        }
    }
    
    class IO: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .IO }
        
        fileprivate(set) var read: CGFloat = 0 // MB
        fileprivate(set) var write: CGFloat = 0 // MB
        fileprivate(set) var readDelta: CGFloat = 0 // MB/s
        fileprivate(set) var writeDelta: CGFloat = 0 // MB/s
        
        func reset() {
            read = 0
            write = 0
            readDelta = 0
            writeDelta = 0
        }
    }
    
    class Diagnostic: DSPMetricsMItemProtocol {
        var type: DSPMetrics.T { .Diagnostic }
        
        fileprivate(set) var amperage: CGFloat = 0 // mA
        fileprivate(set) var voltage: CGFloat = 0 // V
        fileprivate(set) var battery: CGFloat = 0 // 1 - 100
        fileprivate(set) var temperature: CGFloat = 0 // °C
        
        func reset() {
            amperage = 0
            voltage = 0
            battery = 0
            temperature = 0
        }
    }
}
