//
//  CoreProfileSessionTap+Parser.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/9.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    class Parser {
        weak var delegate: IInstrumentsCoreProfileSessionTapDelegate? = nil
        
        private lazy var kParser = KTParser()
        private lazy var dParser = KDebugParser()
        
        public func parse(_ data: Data) {
            guard data.count > 0 else {
                return
            }

            let version = Data(data.prefix(4))
            if version == Data([0x07, 0x58, 0xA2, 0x59]) {
//                delegate?.parserV1(kParser.parse(data))
            } else if version == Data([0x00, 0x02, 0xaa, 0x55]) {
//                delegate?.parserV2(dParser.parseV2(data))
            } else if version == Data([0x00, 0x03, 0xaa, 0x55]) {
//                delegate?.parserV3(dParser.parseV3(data))
            } else {
                print(version)
                delegate?.parserV4(dParser.parseNormal(data))
            }
        }
    }
}
