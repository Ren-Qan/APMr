//
//  HomepageInstrumentsModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/29.
//

import Foundation

enum PerformanceIndicatorType {
    case cpu
    case gpu
    case fps
    case memory
    case network
    case io
    case diagnostic
    
    var name: String {
        return "\(self)".capitalized
    }
}

protocol PerformanceIndicatorInterface {
    var recordSecond: CGFloat { get }
    var indicators: [PerformanceIndicatorProtocol] { get }
}

class PerformanceIndicator: PerformanceIndicatorInterface {
    var seconds: CGFloat = 0
    let cpu = PCPUIndicator()
    let gpu = PGPUIndicator()
    let fps = PFPSIndicator()
    let memory = PMemoryIndicator()
    let network = PNetworkIndicator()
    let io = PIOIndicator()
    let diagnostic = PDiagnosticIndicator()
    
    var recordSecond: CGFloat {
        return seconds
    }
    
    var indicators: [PerformanceIndicatorProtocol] {
        return [cpu, gpu, fps, memory, network, io, diagnostic]
    }
}

class PBaseIndicator {
    struct Indicator {
        var value: CGFloat
        var name: String
        var chartEnable: Bool = true
        
        fileprivate func chart(_ enable: Bool) -> Self {
            if self.chartEnable == enable {
                return self
            }
            
            var item = self
            item.chartEnable = enable
            return item
        }
    }
}

protocol PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { get }
    
    var values: [PBaseIndicator.Indicator] { get }
}

class PCPUIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .cpu }
    var process: CGFloat = 0 // 0 - 100
    var total: CGFloat = 0 // 0 - 100
    
    var values: [PBaseIndicator.Indicator] {
        return [
            total.creat("total"),
            process.creat("process"),
        ]
    }
}

class PMemoryIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .memory }
    var resident: CGFloat = 0 // MB
    var memory: CGFloat = 0 // MB
    var vm: CGFloat = 0 // GB
    
    var values: [PBaseIndicator.Indicator] {
        return [
            resident.creat("resident"),
            memory.creat("memory"),
            vm.creat("vm"),
        ]
    }
}

class PFPSIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .fps }
    var fps: CGFloat = 0
    var jank: Int = 0
    var bigJank: Int = 0
    var stutter: CGFloat = 0
    
    var values: [PBaseIndicator.Indicator] {
        return [
            fps.creat("fps"),
            CGFloat(jank).creat("jank"),
            CGFloat(bigJank).creat("bigJank"),
            stutter.creat("stutter"),
        ]
    }
}

class PGPUIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .gpu }
    var device: CGFloat = 0 // 0 - 100
    var renderer: CGFloat = 0 // 0 - 100
    var tiler: CGFloat = 0 // 0 - 100
    
    var values: [PBaseIndicator.Indicator] {
        return [
            device.creat("device"),
            renderer.creat("renderer"),
            tiler.creat("tiler"),
        ]
    }
}

class PNetworkIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .network }
    var down: CGFloat = 0
    var up: CGFloat = 0
    var downDelta: CGFloat = 0 // KB/s
    var upDelta: CGFloat = 0 // KB/s
    
    var values: [PBaseIndicator.Indicator] {
        return [
            down.creat("down").chart(false),
            up.creat("up").chart(false),
            downDelta.creat("downDelta"),
            upDelta.creat("upDelta"),
        ]
    }
}

class PIOIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .io }
    var read: CGFloat = 0 // KB
    var write: CGFloat = 0 // KB
    var readDelta: CGFloat = 0 // KB/s
    var writeDelta: CGFloat = 0 // KB/s
    
    var values: [PBaseIndicator.Indicator] {
        return [
            read.creat("read").chart(false),
            write.creat("write").chart(false),
            readDelta.creat("readDelta"),
            writeDelta.creat("writeDelta"),
        ]
    }
}

class PDiagnosticIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .diagnostic }
    var amperage: CGFloat = 0 // mA
    var voltage: CGFloat = 0 // V
    var battery: CGFloat = 0 // 1 - 100
    var temperature: CGFloat = 0 // °C
    
    var values: [PBaseIndicator.Indicator] {
        return [
            amperage.creat("amperage"),
            voltage.creat("voltage"),
            battery.creat("battery"),
            temperature.creat("temperature"),
        ]
    }
}

private extension CGFloat {
    func creat(_ name: String) -> PBaseIndicator.Indicator {
        return .init(value: self, name: name)
    }
}
