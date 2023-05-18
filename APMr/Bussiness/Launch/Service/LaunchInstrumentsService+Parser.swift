//
//  LaunchInstrumentsService+Parser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/27.
//

import Foundation

extension LaunchInstrumentsService {
    class Parser {
        public var tracePid: UInt32 = 0
        public var codes: [Int64 : String]? = nil
        public var machTime: IInstruments.DeviceInfo.MT? = nil
        private var threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
        
        private var notes: [IInstruments.CoreProfileSessionTap.KDEBUGElement] = []
    }
}

extension LaunchInstrumentsService.Parser {
    private func time(_ element: IInstruments.CoreProfileSessionTap.KDEBUGElement) -> CGFloat {
        guard let machTime = machTime else { return 0 }
        let time = machTime.format(time: Int64(element.timestamp))
        return time
    }
}

extension LaunchInstrumentsService.Parser {
    func merge(_ threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap]) {
        self.threadMap.merge(threadMap) { current, _ in current }
    }
    
    func decode(_ element: IInstruments.CoreProfileSessionTap.KDEBUGElement) {

    }
    
    func trace(_ model: IInstruments.CoreProfileSessionTap.ModelV1) {
        guard let machTime = machTime else {
            return
        }
        model.elements.forEach { e in
            switch e.element {
                case .STACKSHOT_DURATION(let time):
                    let t = CGFloat(time.stackshot_duration_outer) * machTime.mach_time_factor
                    print(t / 1000000)
                default: return
            }
        }
    }
}




