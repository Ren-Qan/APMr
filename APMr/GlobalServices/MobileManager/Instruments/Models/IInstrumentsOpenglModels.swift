//
//  IInstrumentsOpenglModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/8.
//

import Cocoa
import ObjectMapper

struct IInstrumentsOpenglInfo: Mappable {
    var AllocatedPBSize: Int = 0
    var Allocsystemmemory: Int = 0
    var CoreAnimationFramesPerSecond: Int = 0
    var DeviceUtilization: Int = 0
    var Inusesystemmemory: Int = 0
    var IOGLBundleName: String?
    var recoveryCount: Int = 0
    var RendererUtilization: Int = 0
    var SplitSceneCount: Int = 0
    var TiledSceneBytes: Int = 0
    var TilerUtilization: Int = 0
    var XRVideoCardRunTimeStamp: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        AllocatedPBSize              <- map["Allocated PB Size"]
        Allocsystemmemory            <- map["Alloc system memory"]
        CoreAnimationFramesPerSecond <- map["CoreAnimationFramesPerSecond"]
        DeviceUtilization            <- map["Device Utilization %"]
        Inusesystemmemory            <- map["In use system memory"]
        IOGLBundleName               <- map["IOGLBundleName"]
        recoveryCount                <- map["recoveryCount"]
        RendererUtilization          <- map["Renderer Utilization %"]
        SplitSceneCount              <- map["SplitSceneCount"]
        TiledSceneBytes              <- map["TiledSceneBytes"]
        TilerUtilization             <- map["Tiler Utilization %"]
        XRVideoCardRunTimeStamp      <- map["XRVideoCardRunTimeStamp"]
    }
}

