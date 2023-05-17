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
        let filter = [0x1f, 0x2b, 0x31, 0x31ca0006]
        
        
        guard let thread = threadMap[element.thread] else {
            return
        }
        
        let time = time(element)
        if thread.pid == tracePid {
            print("[\(thread.process)] [class : \(element.class_code)]")
        }
//        if element.class_code == 0x1f {
//            print("[\(thread.process)] === dyld - \(time)")
//        } else if element.class_code == 0x31 {
//            print("[\(thread.process)] === launch end - \(time)")
//        } else if element.class_code == 0x2b {
//            print("[\(thread.process)] === launching - \(time)")
//        } else {
//            print("end")
//        }
    }
    
    func trace(_ model: IInstruments.CoreProfileSessionTap.ModelV1) {
        
    }
}




