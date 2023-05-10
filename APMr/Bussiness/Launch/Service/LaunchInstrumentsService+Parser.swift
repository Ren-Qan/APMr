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
    }
}

extension LaunchInstrumentsService.Parser {
    func merge(_ threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap]) {
        self.threadMap.merge(threadMap) { current, _ in
            current
        }
    }
    
    func decode(_ entry: IInstruments.CoreProfileSessionTap.KDEBUGEntry) {
        guard let thread = threadMap[entry.thread] else {
            return
        }
        
        print(String(format: "[\(thread.process)] - 0x%X", entry.class_code))
        
    }
}




