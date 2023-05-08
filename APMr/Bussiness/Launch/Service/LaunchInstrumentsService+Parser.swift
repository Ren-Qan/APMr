//
//  LaunchInstrumentsService+Parser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/27.
//

import Foundation

extension LaunchInstrumentsService {
    class Parser {
        public var codes: [Int64 : String] = [:]
        public var machTime: [Any] = []
        
        public var tracePid: UInt32 = 0
    }
}

extension LaunchInstrumentsService.Parser {
    
    func decode(_ entry: IInstruments.CoreProfileSessionTap.KDEBUGEntry) {
//        let list: [UInt32] = [0x1f, 0x2b, 0x31]
//        if list.contains([entry.class_code]) {
//            decodeAppLifeCycle(entry)
//        } else if entry.debug_id == 835321862 {
//            print("阶段")
//        }
        
        decodeAppLifeCycle(entry)
    }
    
    func decodeAppLifeCycle(_ entry: IInstruments.CoreProfileSessionTap.KDEBUGEntry) {
//        guard let process = threadMap[entry.thread], process.pid == tracePid, tracePid != 0 else {
//            return
//        }
        
//        print("[\(process.process) ---\(entry.debug_id) ==== \(entry.class_code) ==== \(entry.subclass_code) === \(entry.action_code) === \(entry.func_code)]")
    }
    
}




