//
//  CoreParser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/23.
//

import Foundation

class CoreParser {
    var tracePid: PID? = nil
    var traceCodes: [Int64 : String]? = nil
    var traceMachTime: IInstruments.DeviceInfo.MT? = nil
    
    private var threadMap: [TID : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
    
    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}

extension CoreParser {
    func merge(_ threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap]) {
        self.threadMap.merge(threadMap) { current, _ in current }
    }
    
    func feeds(_ elements: [IInstruments.CoreProfileSessionTap.KDEBUGElement]) {
        queue.addOperation { [weak self] in
            elements.forEach { e in
                self?.feed(e)
            }
        }
    }
}

extension CoreParser {
    private func feed(_ element: IInstruments.CoreProfileSessionTap.KDEBUGElement) {
        
    }
}
