//
//  IInstrumentsSysmotapModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/5.
//

import Cocoa
import ObjectMapper

extension IInstruments.Sysmontap {
    struct ProcessesModel: Mappable {
        var Processes: [Int64 : Any] = [:]
        var StartMachAbsTime: Int64 = 0
        var EndMachAbsTime: Int64 = 0
        var type: Int64 = 0
        
        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            Processes   <- map["Processes"]
            StartMachAbsTime <- map["StartMachAbsTime"]
            EndMachAbsTime  <- map["EndMachAbsTime"]
            type   <- map["Type"]
        }
        
        func processModel(pid: Int64) -> IInstruments.Sysmontap.SystemProcessesModel? {
            guard let datas = Processes[pid] as? [Any],
                  datas.count == IInstruments.Sysmontap.PA.count else {
                return nil
            }
            
            // 属性与IInstrumentsSysmontap.PA一一对应
            var model = IInstruments.Sysmontap.SystemProcessesModel()
            model.cpuUsage = datas[0] as? CGFloat ?? 0
            model.ctxSwitch = datas[1] as? Int64 ?? 0
            model.intWakeups = datas[2] as? Int64 ?? 0
            model.physFootprint = datas[3] as? Int64 ?? 0
            model.memVirtualSize = datas[4] as? Int64 ?? 0
            model.memResidentSize = datas[5] as? Int64 ?? 0
            model.memAnon = datas[6] as? Int64 ?? 0
            model.pid = datas[7] as? Int64 ?? 0
            model.name = datas[8] as? String
            model.diskBytesWritten = datas[9] as? Int64 ?? 0
            model.diskBytesRead = datas[10] as? Int64 ?? 0
            return model
        }
    }
    
    struct Model: Mappable {
        var CPUCount: Int = 0
        var EnabledCPUs: Int = 0
        var EndMachAbsTime: Int = 0
        var PerCPUUsage = [IInstruments.Sysmontap.PerCPUUsage]()
        var ProcessesAttributes = [String]()
        var StartMachAbsTime: Int = 0
        var System = [Int]()
        var SystemAttributes = [String]()
        var SystemCPUUsage: IInstruments.Sysmontap.SystemCPUUsage?
        var type: Int = 0

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            CPUCount            <- map["CPUCount"]
            EnabledCPUs         <- map["EnabledCPUs"]
            EndMachAbsTime      <- map["EndMachAbsTime"]
            PerCPUUsage         <- map["PerCPUUsage"]
            ProcessesAttributes <- map["ProcessesAttributes"]
            StartMachAbsTime    <- map["StartMachAbsTime"]
            System              <- map["System"]
            SystemAttributes    <- map["SystemAttributes"]
            SystemCPUUsage      <- map["SystemCPUUsage"]
            type                <- map["Type"]
        }
    }

    struct PerCPUUsage: Mappable {
        var CPU_NiceLoad: Int = 0
        var CPU_SystemLoad: Int = 0
        var CPU_TotalLoad: Int = 0
        var CPU_UserLoad: Int = 0

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            CPU_NiceLoad   <- map["CPU_NiceLoad"]
            CPU_SystemLoad <- map["CPU_SystemLoad"]
            CPU_TotalLoad  <- map["CPU_TotalLoad"]
            CPU_UserLoad   <- map["CPU_UserLoad"]
        }
    }

    struct SystemCPUUsage: Mappable {
        var CPU_NiceLoad: Int = 0
        var CPU_SystemLoad: Int = 0
        var CPU_TotalLoad: Int = 0
        var CPU_UserLoad: Int = 0

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            CPU_NiceLoad   <- map["CPU_NiceLoad"]
            CPU_SystemLoad <- map["CPU_SystemLoad"]
            CPU_TotalLoad  <- map["CPU_TotalLoad"]
            CPU_UserLoad   <- map["CPU_UserLoad"]
        }
    }

    // MARK: - 与 IInstrumentsSysmontap 请求的参数保持一致(顺序，个数)
    struct SystemProcessesModel {
        var cpuUsage: CGFloat = 0
        var ctxSwitch: Int64 = 0
        var intWakeups: Int64 = 0
        var physFootprint: Int64 = 0
        var memVirtualSize: Int64 = 0
        var memResidentSize: Int64 = 0
        var memAnon: Int64 = 0
        var pid: Int64 = 0
        var name: String?
        var diskBytesWritten: Int64 = 0
        var diskBytesRead: Int64 = 0
    }
}

