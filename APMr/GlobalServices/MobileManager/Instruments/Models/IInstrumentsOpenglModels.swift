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
        AllocatedPBSize              <- map["AllocatedPBSize"]
        Allocsystemmemory            <- map["Allocsystemmemory"]
        CoreAnimationFramesPerSecond <- map["CoreAnimationFramesPerSecond"]
        DeviceUtilization            <- map["DeviceUtilization%"]
        Inusesystemmemory            <- map["Inusesystemmemory"]
        IOGLBundleName               <- map["IOGLBundleName"]
        recoveryCount                <- map["recoveryCount"]
        RendererUtilization          <- map["RendererUtilization%"]
        SplitSceneCount              <- map["SplitSceneCount"]
        TiledSceneBytes              <- map["TiledSceneBytes"]
        TilerUtilization             <- map["TilerUtilization%"]
        XRVideoCardRunTimeStamp      <- map["XRVideoCardRunTimeStamp"]
    }
}

