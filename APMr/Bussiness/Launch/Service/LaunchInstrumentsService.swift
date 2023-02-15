//
//  LaunchInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//


import LibMobileDevice

class LaunchInstrumentsService: NSObject, ObservableObject {
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        group.config([
            .deviceinfo,
        ])
        return group
    }()
}

extension LaunchInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {
        
    }
}
