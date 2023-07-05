//
//  PeformanceInstrumentsModels.swift
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
        switch self {
            case .memory:
                return "Memory"
            case .network:
                return "Network"
            case .io:
                return "I/O"
            case .diagnostic:
                return "Diagnostic"
            default:
                return "\(self)".uppercased()
        }
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
        var unit: String = ""
        
        fileprivate func chart(_ enable: Bool) -> Self {
            if self.chartEnable == enable {
                return self
            }
            
            var item = self
            item.chartEnable = enable
            return item
        }
        
        fileprivate func unit(_ res: String) -> Self {
            if self.unit == res {
                return self
            }
            
            var item = self
            item.unit = res
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
            total.create("total").unit("%"),
            process.create("process").unit("%"),
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
            resident.create("resident").unit("MB"),
            memory.create("memory").unit("MB"),
            vm.create("vm").unit("GB"),
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
            fps.create("fps").unit("frame"),
            CGFloat(jank).create("jank").unit("%"),
            CGFloat(bigJank).create("bigJank").unit("%"),
            stutter.create("stutter").unit("%"),
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
            device.create("device").unit("%"),
            renderer.create("renderer").unit("%"),
            tiler.create("tiler").unit("%"),
        ]
    }
}

class PNetworkIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .network }
    var down: CGFloat = 0
    var up: CGFloat = 0
    var downDelta: CGFloat = 0 // MB/s
    var upDelta: CGFloat = 0 // MB/s
    
    var values: [PBaseIndicator.Indicator] {
        return [
            down.create("down").chart(false).unit("MB"),
            up.create("up").chart(false).unit("MB"),
            downDelta.create("downD").unit("MB/s"),
            upDelta.create("upD").unit("MB/s"),
        ]
    }
}

class PIOIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .io }
    var read: CGFloat = 0 // MB
    var write: CGFloat = 0 // MB
    var readDelta: CGFloat = 0 // MB/s
    var writeDelta: CGFloat = 0 // MB/s
    
    var values: [PBaseIndicator.Indicator] {
        return [
            read.create("read").chart(false).unit("MB"),
            write.create("write").chart(false).unit("MB"),
            readDelta.create("readD").unit("MB/s"),
            writeDelta.create("writeD").unit("MB/s"),
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
            amperage.create("amperage").unit("mA"),
            voltage.create("voltage").unit("V"),
            battery.create("battery").unit("%"),
            temperature.create("temp").unit("°C"),
        ]
    }
}

private extension CGFloat {
    func create(_ name: String) -> PBaseIndicator.Indicator {
        return .init(value: self, name: name)
    }
}
