//
//  IIntrumentsProtocols.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/28.
//

import Cocoa
import LibMobileDevice

enum IInstrumentsServiceName: String, CaseIterable {
    case sysmontap = "com.apple.instruments.server.services.sysmontap"
    
    case opengl = "com.apple.instruments.server.services.graphics.opengl"
    
    case deviceinfo = "com.apple.instruments.server.services.deviceinfo"
    
    case processcontrol = "com.apple.instruments.server.services.processcontrol"
    
    case gpu = "com.apple.instruments.server.services.gpu"
    
    case networkStatistics = "com.apple.xcode.debug-gauge-data-providers.NetworkStatistics"
    
    case networking = "com.apple.instruments.server.services.networking"
    
    case energy = "com.apple.xcode.debug-gauge-data-providers.Energy"
    
    case objectalloc = "com.apple.instruments.server.services.objectalloc"
    
//    case dyld = "com.apple.instruments.server.services.processcontrolbydictionary"
//
//    case notifications = "com.apple.instruments.server.services.mobilenotifications"
    
    var channel: UInt32 {
        return UInt32(IInstrumentsServiceName.allCases.firstIndex(of: self)! + 10)
    }
    
    var callbackChannel: UInt32 {
        return UINT32_MAX - channel + 1
    }
    
    init?(channel: UInt32) {
        let name = IInstrumentsServiceName.allCases.first { name in
            return name.channel == channel || name.callbackChannel == channel
        }
        if let name = name {
            self = name
        } else {
            return nil
        }
    }
}

protocol IInstrumentRequestArgsProtocol {
    var selector: String { get }
    
    var dtxArg: DTXArguments? { get }
}


protocol IInstrumentsServiceProtocol {
    associatedtype Arg : IInstrumentRequestArgsProtocol
    
    var server: IInstrumentsServiceName { get }
    
    var instrument: IInstruments? { get }
    
    func response(_ response: DTXReceiveObject?)
    
    // MARK: - optional
    
    var expectsReply: Bool { get }
            
    func register(_ arg: Arg)
    
    func send(_ arg: Arg)
    
    func set(_ insturments: IInstruments)
    
    func identifier(_ arg: Arg) -> UInt32
    
    func arg(_ identifier: UInt32) -> Arg?
}

extension IInstrumentsServiceProtocol {
    var expectsReply: Bool {
        return true
    }
        
    func set(_ insturments: IInstruments) {
        if let service = self as? IInstrumentsBase {
            service.instrument = insturments
        }
        insturments.setup(service: self)
    }
    
    func identifier(_ arg: Arg) -> UInt32 {
        return .max
    }
    
    func arg(_ identifier: UInt32) -> Arg? {
        return nil
    }
    
    func register(_ arg: Arg) {
        send(arg)
    }
    
    func send(_ arg: Arg) {
        let channel = server.channel        
        instrument?.send(channel: channel,
                         identifier: identifier(arg),
                         selector: arg.selector,
                         dtxArg: arg.dtxArg,
                         expectsReply: expectsReply)
    }
}


//{
//    "com.apple.dt.Instruments.inlineCapabilities" = 1;
//    "com.apple.dt.Xcode.WatchProcessControl" = 3;
//    "com.apple.dt.services.capabilities.vmtracking" = 1;
//    "com.apple.instruments.server.services.ConditionInducer" = 1;
//    "com.apple.instruments.server.services.LocationSimulation" = 1;
//    "com.apple.instruments.server.services.activitytracetap" = 6;
//    "com.apple.instruments.server.services.activitytracetap.deferred" = 1;
//    "com.apple.instruments.server.services.activitytracetap.immediate" = 1;
//    "com.apple.instruments.server.services.activitytracetap.windowed" = 1;
//    "com.apple.instruments.server.services.assets" = 4;
//    "com.apple.instruments.server.services.assets.response" = 2;
//    "com.apple.instruments.server.services.coreml.modelwriter" = 1;
//    "com.apple.instruments.server.services.coreml.perfrunner" = 1;
//    "com.apple.instruments.server.services.coreprofilesessiontap" = 2;
//    "com.apple.instruments.server.services.coreprofilesessiontap.config" = 1;
//    "com.apple.instruments.server.services.coreprofilesessiontap.deferred" = 1;
//    "com.apple.instruments.server.services.coreprofilesessiontap.immediate" = 1;
//    "com.apple.instruments.server.services.coreprofilesessiontap.multipleTimeTriggers" = 1;
//    "com.apple.instruments.server.services.coreprofilesessiontap.pmc" = 2;
//    "com.apple.instruments.server.services.coreprofilesessiontap.pmi" = 2;
//    "com.apple.instruments.server.services.coreprofilesessiontap.windowed" = 1;
//    "com.apple.instruments.server.services.coresampling" = 10;
//    "com.apple.instruments.server.services.device.applictionListing" = 1;
//    "com.apple.instruments.server.services.device.xpccontrol" = 2;
//    "com.apple.instruments.server.services.deviceinfo" = 113;
//    "com.apple.instruments.server.services.deviceinfo.app-life-cycle" = 1;
//    "com.apple.instruments.server.services.deviceinfo.condition-inducer" = 1;
//    "com.apple.instruments.server.services.deviceinfo.devicesymbolication" = 1;
//    "com.apple.instruments.server.services.deviceinfo.dyld-tracing" = 1;
//    "com.apple.instruments.server.services.deviceinfo.energytracing.location" = 1;
//    "com.apple.instruments.server.services.deviceinfo.gcd-perf" = 1;
//    "com.apple.instruments.server.services.deviceinfo.gpu-allocation" = 1;
//    "com.apple.instruments.server.services.deviceinfo.metal" = 1;
//    "com.apple.instruments.server.services.deviceinfo.recordOptions" = 1;
//    "com.apple.instruments.server.services.deviceinfo.scenekit-tracing" = 1;
//    "com.apple.instruments.server.services.deviceinfo.systemversion" = 160100;
//    "com.apple.instruments.server.services.filetransfer" = 1;
//    "com.apple.instruments.server.services.filetransfer.debuginbox" = 1;
//    "com.apple.instruments.server.services.gpu" = 1;
//    "com.apple.instruments.server.services.gpu.counters" = 4;
//    "com.apple.instruments.server.services.gpu.counters.multisources" = 1;
//    "com.apple.instruments.server.services.gpu.deferred" = 1;
//    "com.apple.instruments.server.services.gpu.immediate" = 1;
//    "com.apple.instruments.server.services.gpu.performancestate" = 2;
//    "com.apple.instruments.server.services.gpu.shaderprofiler" = 1;
//    "com.apple.instruments.server.services.graphics.coreanimation" = 1;
//    "com.apple.instruments.server.services.graphics.coreanimation.deferred" = 1;
//    "com.apple.instruments.server.services.graphics.coreanimation.immediate" = 1;
//    "com.apple.instruments.server.services.graphics.opengl" = 1;
//    "com.apple.instruments.server.services.graphics.opengl.deferred" = 1;
//    "com.apple.instruments.server.services.graphics.opengl.immediate" = 1;
//    "com.apple.instruments.server.services.httparchiverecording" = 2;
//    "com.apple.instruments.server.services.mobilenotifications" = 2;
//    "com.apple.instruments.server.services.networking" = 2;
//    "com.apple.instruments.server.services.networking.deferred" = 1;
//    "com.apple.instruments.server.services.networking.immediate" = 1;
//    "com.apple.instruments.server.services.objectalloc" = 5;
//    "com.apple.instruments.server.services.objectalloc.deferred" = 1;
//    "com.apple.instruments.server.services.objectalloc.immediate" = 1;
//    "com.apple.instruments.server.services.objectalloc.zombies" = 1;
//    "com.apple.instruments.server.services.processcontrol" = 107;
//    "com.apple.instruments.server.services.processcontrol.capability.memorylimits" = 1;
//    "com.apple.instruments.server.services.processcontrol.capability.signal" = 1;
//    "com.apple.instruments.server.services.processcontrol.feature.deviceio" = 103;
//    "com.apple.instruments.server.services.processcontrolbydictionary" = 4;
//    "com.apple.instruments.server.services.remoteleaks" = 9;
//    "com.apple.instruments.server.services.remoteleaks.deferred" = 1;
//    "com.apple.instruments.server.services.remoteleaks.immediate" = 1;
//    "com.apple.instruments.server.services.sampling" = 11;
//    "com.apple.instruments.server.services.sampling.deferred" = 1;
//    "com.apple.instruments.server.services.sampling.immediate" = 1;
//    "com.apple.instruments.server.services.screenshot" = 2;
//    "com.apple.instruments.server.services.storekit" = 4;
//    "com.apple.instruments.server.services.sysmontap" = 3;
//    "com.apple.instruments.server.services.sysmontap.deferred" = 1;
//    "com.apple.instruments.server.services.sysmontap.immediate" = 1;
//    "com.apple.instruments.server.services.sysmontap.processes" = 1;
//    "com.apple.instruments.server.services.sysmontap.system" = 1;
//    "com.apple.instruments.server.services.sysmontap.windowed" = 1;
//    "com.apple.instruments.server.services.ultraviolet.agent-pipe" = 1;
//    "com.apple.instruments.server.services.ultraviolet.preview" = 1;
//    "com.apple.instruments.server.services.ultraviolet.renderer" = 1;
//    "com.apple.instruments.server.services.vmtracking" = 1;
//    "com.apple.instruments.server.services.vmtracking.deferred" = 1;
//    "com.apple.instruments.server.services.vmtracking.immediate" = 1;
//    "com.apple.instruments.target.ios" = 160100;
//    "com.apple.instruments.target.logical-cpus" = 6;
//    "com.apple.instruments.target.mtb.denom" = 3;
//    "com.apple.instruments.target.mtb.numer" = 125;
//    "com.apple.instruments.target.physical-cpus" = 6;
//    "com.apple.instruments.target.user-page-size" = 16384;
//    "com.apple.private.DTXBlockCompression" = 2;
//    "com.apple.private.DTXConnection" = 1;
//    "com.apple.xcode.debug-gauge-data-providers.Energy" = 1;
//    "com.apple.xcode.debug-gauge-data-providers.NetworkStatistics" = 1;
//    "com.apple.xcode.debug-gauge-data-providers.SceneKit" = 1;
//    "com.apple.xcode.debug-gauge-data-providers.SpriteKit" = 1;
//    "com.apple.xcode.debug-gauge-data-providers.procinfo" = 1;
//    "com.apple.xcode.debug-gauge-data-providers.resources" = 1;
//    "com.apple.xcode.resource-control" = 1;
//}
