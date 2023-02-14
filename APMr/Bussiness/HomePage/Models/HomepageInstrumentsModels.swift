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
            total.creat("total").unit("%"),
            process.creat("process").unit("%"),
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
            resident.creat("resident").unit("MB"),
            memory.creat("memory").unit("MB"),
            vm.creat("vm").unit("GB"),
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
            fps.creat("fps").unit("frame"),
            CGFloat(jank).creat("jank").unit("%"),
            CGFloat(bigJank).creat("bigJank").unit("%"),
            stutter.creat("stutter").unit("%"),
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
            device.creat("device").unit("%"),
            renderer.creat("renderer").unit("%"),
            tiler.creat("tiler").unit("%"),
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
            down.creat("down").chart(false).unit("MB"),
            up.creat("up").chart(false).unit("MB"),
            downDelta.creat("downD").unit("MB/s"),
            upDelta.creat("upD").unit("MB/s"),
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
            read.creat("read").chart(false).unit("MB"),
            write.creat("write").chart(false).unit("MB"),
            readDelta.creat("readD").unit("MB/s"),
            writeDelta.creat("writeD").unit("MB/s"),
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
            amperage.creat("amperage").unit("mA"),
            voltage.creat("voltage").unit("V"),
            battery.creat("battery").unit("%"),
            temperature.creat("temp").unit("°C"),
        ]
    }
}

private extension CGFloat {
    func creat(_ name: String) -> PBaseIndicator.Indicator {
        return .init(value: self, name: name)
    }
}
