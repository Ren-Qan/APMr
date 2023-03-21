//
//  IInstrumentsEnergyModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/4.
//

import Cocoa
import ObjectMapper

struct IInstrumentsEnergyModel: Mappable {
    var energy_appstate_cost: Int = 0
    var energy_appstate_overhead: Int = 0
    var energy_cost: CGFloat = 0
    var energy_cpu_cost: CGFloat = 0
    var energy_cpu_overhead: Int = 0
    var energy_display_cost: CGFloat = 0
    var energy_display_overhead: Int = 0
    var energy_gpu_cost: CGFloat = 0
    var energy_gpu_overhead: Int = 0
    var energy_inducedthermalstate_cost: Int = 0
    var energy_location_cost: CGFloat = 0
    var energy_location_overhead: Int = 0
    var energy_networking_cost: Int = 0
    var energy_networkning_overhead: Int = 0
    var energy_overhead: Int = 0
    var energy_thermalstate_cost: Int = 0
    var energy_version: Int = 0
    var kIDEGaugeSecondsSinceInitialQueryKey: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        energy_appstate_cost <- map["energy.appstate.cost", nested: false]
        energy_appstate_overhead <- map["energy.appstate.overhead", nested: false]
        energy_cost <- map["energy.cost", nested: false]
        energy_cpu_cost <- map["energy.cpu.cost", nested: false]
        energy_cpu_overhead <- map["energy.cpu.overhead", nested: false]
        energy_display_cost <- map["energy.display.cost", nested: false]
        energy_display_overhead <- map["energy.display.overhead", nested: false]
        energy_gpu_cost <- map["energy.gpu.cost", nested: false]
        energy_gpu_overhead <- map["energy.gpu.overhead", nested: false]
        energy_inducedthermalstate_cost <- map["energy.inducedthermalstate.cost", nested: false]
        energy_location_cost <- map["energy.location.cost", nested: false]
        energy_location_overhead <- map["energy.location.overhead", nested: false]
        energy_networking_cost <- map["energy.networking.cost", nested: false]
        energy_networkning_overhead <- map["energy.networkning.overhead", nested: false]
        energy_overhead <- map["energy.overhead", nested: false]
        energy_thermalstate_cost <- map["energy.thermalstate.cost", nested: false]
        energy_version <- map["energy.version", nested: false]
        kIDEGaugeSecondsSinceInitialQueryKey <- map["kIDEGaugeSecondsSinceInitialQueryKey"]
    }
}
