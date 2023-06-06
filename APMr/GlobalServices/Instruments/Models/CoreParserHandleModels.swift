//
//  CoreParserHandleModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/2.
//

import Foundation

extension CoreParser.Handle.CallStack {
    struct CS {
        let timestamp: CGFloat
        let tid: TID
        let tpMap: IInstruments.CoreProfileSessionTap.KDThreadMap? 
        let frames: [CSFrame]
    }
    
    struct DYLD {
        let frame: Frame
        let uuid: UUID
    }
    
    struct CSFrame {
        let frame: Frame
        let uuid: UUID?
        let offset: Frame?
    }
}
