//
//  IInstproxyModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import ObjectMapper

struct IApp: Mappable, Identifiable {
    enum AppType: String {
        case other
        case user = "User"
        case system = "System"
    }
    
    var id: String { bundleId }
    
    var path: String = ""
    var name: String = ""
    var bundleId: String = ""
    var container: String = ""
    var signerIdentity: String?
    var applicationType: AppType = .other
    var executableName: String = ""
    
    var isDeveloping: Bool {
        guard let signer = signerIdentity else {
            return false
        }
        
        if !signer.hasPrefix("Apple"), signer.contains("Developer") {
            return true
        }
        
        if signer.contains("Apple Development") {
            return true
        }
        
        return false
    }
    
    init?(map: ObjectMapper.Map) {}
    
    mutating func mapping(map: ObjectMapper.Map) {
        name <- map["CFBundleDisplayName"]
        bundleId <- map["CFBundleIdentifier"]
        container <- map["Container"]
        signerIdentity <- map["SignerIdentity"]
        applicationType <- map["ApplicationType"]
        path <- map["BundlePath"]
        executableName <- map["CFBundleExecutable"]
    }
}
