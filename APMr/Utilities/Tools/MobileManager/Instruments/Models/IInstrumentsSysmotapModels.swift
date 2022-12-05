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
