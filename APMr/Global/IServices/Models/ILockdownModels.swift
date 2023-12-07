//
//  ILockdownModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import ObjectMapper

struct ILockdownDeivceInfo: Mappable {
    var deivceName: String = ""
    var osVersion: String = ""
    
    init?(map: ObjectMapper.Map) {
        
    }
    
    mutating func mapping(map: ObjectMapper.Map) {
        deivceName <- map["DeviceName"]
        osVersion <- map["ProductVersion"]
    }
}
