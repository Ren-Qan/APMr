//
//  PerformanceService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import Foundation

class PerformanceService: NSObject, ObservableObject {
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let sysmontap = IInstruments.Sysmontap()
        sysmontap.delegate = self
        
        let opengl = IInstruments.Opengl()
        opengl.delegate = self
        
        let process = IInstruments.Processcontrol()
        process.delegate = self
        
        let net = IInstruments.NetworkStatistics()
        net.delegate = self
                
        let group = IInstrumentsServiceGroup()
        group.config([sysmontap, opengl, process, net])
        
        return group
    }()
}

extension PerformanceService: IInstrumentsSysmontapDelegate {
    
}

extension PerformanceService: IInstrumentsOpenglDelegate {
    
}

extension PerformanceService: IInstrumentsProcesscontrolDelegate {
    
}

extension PerformanceService: IInstrumentsNetworkStatisticsDelegate {
    
}
