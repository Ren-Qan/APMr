//
//  CoreProfileSessionTap+KTrace.swift
//  APMr
//
//  Created by 任玉乾 on 2023/5/9.
//

import Foundation

extension IInstruments.CoreProfileSessionTap {
    class KTParser {
        func parse(_ data: Data) {
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

                let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(size))
                offset = stream.read(dataP, maxLength: Int(size))
                let data = Data(bytes: dataP, count: Int(size))

                var kt = IInstruments.CoreProfileSessionTap.KT.KCDATA_TYPE_INVALID
                if let k = IInstruments.CoreProfileSessionTap.KT(rawValue: type) {
                    kt = k
                }

                let item = IInstruments.CoreProfileSessionTap.KCData(type: kt,
                                                                     size: size,
                                                                     flag: flag,
                                                                     data: data)
            }

            stream.close()
        }
    }
}



