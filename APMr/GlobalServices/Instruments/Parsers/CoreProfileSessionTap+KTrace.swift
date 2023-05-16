//
//  CoreProfileSessionTap+KTrace.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/9.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    class KTParser {
        func parse(_ data: Data) -> ModelV1 {
            var elements = [KCData]()
            var offset = 0
            let stream = InputStream(data: data)
            stream.open()
            
            while stream.hasBytesAvailable {
                var type: UInt32 = 0
                var size: UInt32 = 0
                var flag: UInt64 = 0
                
                offset += stream.read(&type, maxLength: 4)
                offset += stream.read(&size, maxLength: 4)
                offset += stream.read(&flag, maxLength: 8)
                let data = stream.data(Int(size))
                
                var kt = IInstruments.CoreProfileSessionTap.KT.KCDATA_TYPE_INVALID
                if let k = IInstruments.CoreProfileSessionTap.KT(rawValue: type) {
                    kt = k
                }
                
                let item = IInstruments.CoreProfileSessionTap.KCData(type: kt,
                                                                     size: size,
                                                                     flag: flag,
                                                                     data: data)
                elements.append(item)
            }
            
            stream.close()
            return ModelV1(elements: elements)
        }
    }
}



