//
//  IInstrumentsAppLifeCycle.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/17.
//

import Foundation
import LibMobileDevice

protocol IInstrumentsAppLifeCycleDelegate: NSObjectProtocol {
    
}

class IInstrumentsAppLifeCycle: IInstrumentsBase {
    public weak var delegate: IInstrumentsAppLifeCycleDelegate? = nil
}

extension IInstrumentsAppLifeCycle: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .applifecycle
    }
    
    func response(_ response: DTXReceiveObject) {
        print("APPLife [Arr]==== \(response.array)")
        print("APPLife [Objc]==== \(response.object)")
    }
}
