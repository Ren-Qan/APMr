//
//  IInstrumentsBase.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import Foundation

class IInstrumentsBase {    
    public weak var instrument: IInstruments? = nil
    public var identifier: UInt32 = 0
    public var nextIndentifier: UInt32 {
        identifier += 1
        return identifier
    }
}
