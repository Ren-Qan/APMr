//
//  IInstrumentsSysmotapModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/5.
//

import Cocoa
import ObjectMapper

struct IInstrumentsSysmotapProcessesInfo: Mappable {
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
    
    func processInfo(pid: Int64) -> IInstrumentsSysmotapSystemProcessesModel? {
        guard let datas = Processes[pid] as? [Any],
              datas.count == 9 else {
            return nil
        }
        
        var model = IInstrumentsSysmotapSystemProcessesModel()
        model.cpuUsage = datas[0] as? CGFloat ?? 0
        model.ctxSwitch = datas[1] as? Int64 ?? 0
        model.intWakeups = datas[2] as? Int64 ?? 0
        model.physFootprint = datas[3] as? Int64 ?? 0
        model.memVirtualSize = datas[4] as? Int64 ?? 0
        model.memResidentSize = datas[5] as? Int64 ?? 0
        model.memAnon = datas[6] as? Int64 ?? 0
        model.pid = datas[7] as? Int64 ?? 0
        model.name = datas[8] as? String
        return model
    }
}

struct IInstrumentsSysmotapInfo: Mappable {
    var CPUCount: Int = 0
    var EnabledCPUs: Int = 0
    var EndMachAbsTime: Int = 0
    var PerCPUUsage = [IInstrumentsSysmotapPerCPUUsage]()
    var ProcessesAttributes = [String]()
    var StartMachAbsTime: Int = 0
    var System = [Int]()
    var SystemAttributes = [String]()
    var SystemCPUUsage: IInstrumentsSysmotapSystemCPUUsage?
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

struct IInstrumentsSysmotapPerCPUUsage: Mappable {
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

struct IInstrumentsSysmotapSystemCPUUsage: Mappable {
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

// MARK: - 与 IInstrumentsSysmontap 请求的参数保持一致
struct IInstrumentsSysmotapSystemProcessesModel {
    var cpuUsage: CGFloat = 0
    var ctxSwitch: Int64 = 0
    var intWakeups: Int64 = 0
    var physFootprint: Int64 = 0
    var memVirtualSize: Int64 = 0
    var memResidentSize: Int64 = 0
    var memAnon: Int64 = 0
    var pid: Int64 = 0
    var name: String?
}
