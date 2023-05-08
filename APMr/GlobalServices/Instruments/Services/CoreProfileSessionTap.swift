//
//  CoreProfileSessionTap.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/22.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsCoreProfileSessionTapDelegate: NSObjectProtocol {
    func praserV1(_ model: IInstruments.CoreProfileSessionTap.ModelV1)
    func praserV2(_ model: IInstruments.CoreProfileSessionTap.ModelV2)
    func praserV4(_ model: IInstruments.CoreProfileSessionTap.ModelV4)
}

extension IInstruments {
    class CoreProfileSessionTap: Base {
        public weak var delegate: IInstrumentsCoreProfileSessionTapDelegate? = nil
    }
}

extension IInstruments.CoreProfileSessionTap: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .coreprofilesessiontap
    }
    
    func response(_ response: IInstruments.R) {
        if let dic = response.object as? [String : Any] {
            if let data = (dic["sm"] as? [String : Any])?["ktrace"] as? Data {
                parse(data)
            }
        } else if let data = response.object as? Data {
            parse(data)
        }
    }
}

extension IInstruments.CoreProfileSessionTap {
    func start() {
        send(P.start.arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
    
    func setConfig() {
        send(P.setConfig.arg)
    }
}

extension IInstruments.CoreProfileSessionTap {
    enum P {
        case start
        case stop
        case setConfig
        
        var arg: IInstrumentArgs {
            switch self {
                case .start: return IInstrumentArgs("start")
                case .stop: return IInstrumentArgs("stop")
                case .setConfig:
                    let config: [String : Any] =
                    [
                        "tc": [
                            [
                                "kdf2": [735576064, 19202048, 67895296, 835321856, 735838208, 554762240,
                                         730267648, 520552448, 117440512, 19922944, 17563648, 17104896, 17367040,
                                         771686400, 520617984, 20971520, 520421376],
                                "csd": 128,
                                "tk": 3,
                                "ta": [[3], [0], [2], [1, 1, 0]],
                                "uuid": UUID().uuidString.uppercased(),
                            ] as [String : Any],
                            [
                                "tsf": [65537],
                                "ta": [[0], [2], [1, 1, 0]],
                                "si": 5000000,
                                "tk": 1,
                                "uuid": UUID().uuidString.uppercased(),
                            ],
                        ],
                        "rp": 100,
                        "bm": 1,
                    ]
                    let arg = DTXArguments()
                    arg.append(config)
                    return IInstrumentArgs("setConfig:", dtxArg: arg)
            }
        }
    }
}

extension IInstruments.CoreProfileSessionTap {
    fileprivate func parse(_ data: Data) {
        guard data.count > 0 else {
            return
        }
        
        let version = Data(data.prefix(4))
        if version ==  Data([0x07, 0x58, 0xA2, 0x59]) {
            p1(data)
        } else if version == Data([0x00, 0x02, 0xaa, 0x55]) {
            p2(data)
        } else if version == Data([0x00, 0x03, 0xaa, 0x55]) {
            p2(data)
        } else {
            p4(data)
        }
    }
    
    private func p1(_ data: Data) {
        var offset = 0
        var entries = [IInstruments.CoreProfileSessionTap.KCData]()
        
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
            
            let item = IInstruments.CoreProfileSessionTap.KCData(type: type, size: size, flag: flag, data: data)
            entries.append(item)
        }
        
        stream.close()
        
        let model = IInstruments.CoreProfileSessionTap.ModelV1(entries: entries)
        self.delegate?.praserV1(model)
    }
    
    private func p2(_ data: Data) {
        var threadMap: [UInt64 : IInstruments.CoreProfileSessionTap.KDThreadMap] = [:]
        var entries: [IInstruments.CoreProfileSessionTap.KDEBUGEntry] = []
        
        var offset = 0
        
        let stream = InputStream(data: data)
        stream.open()
        
        var header = IInstruments.CoreProfileSessionTap.KDHeaderV2()
        offset += stream.read(&header, maxLength: MemoryLayout<IInstruments.CoreProfileSessionTap.KDHeaderV2>.size)
        
        let empty = UnsafeMutablePointer<UInt8>.allocate(capacity: 0x100)
        offset += stream.read(empty, maxLength: 0x100)
        empty.deallocate()
        
        let mapCount = Int(header.number_of_treads)
        var threadI = 0
        
        while stream.hasBytesAvailable, threadI < mapCount {
            var thread = IInstruments.CoreProfileSessionTap.KDThreadMap()
            
            offset += stream.read(&thread.thread, maxLength: 8)
            offset += stream.read(&thread.pid, maxLength: 4)
            
            let cStringsData = UnsafeMutablePointer<UInt8>.allocate(capacity: 20)
            offset += stream.read(cStringsData, maxLength: 20)
            var i = 0
            var cString = [UInt8]()
            while i < 20, (cStringsData + i).pointee != 0 {
                cString.append((cStringsData + i).pointee)
                i += 1
            }
            cString.append(0)
            cStringsData.deallocate()
            
            thread.process = String(cString: cString)
            threadI += 1
            threadMap[thread.thread] = thread
        }
        
        var e: UInt8 = 0
        while (offset < data.count && e == 0) {
            e = UInt8(data[offset])
            if e == 0 {
                offset += stream.read(&e, maxLength: 1)
            }
        }
        
        while stream.hasBytesAvailable {
            var entry = IInstruments.CoreProfileSessionTap.KDEBUGEntry()
            stream.read(&entry, maxLength: 64)
            entries.append(entry)
        }
        
        stream.close()
        
        delegate?.praserV2(.init(threadMap: threadMap, entries: entries))
    }
    
    private func p3(_ data: Data) {
        var offset = 0
        let stream = InputStream(data: data)
        stream.open()
        
        let header = UnsafeMutablePointer<IInstruments.CoreProfileSessionTap.KDHeaderV3>.allocate(capacity: 1)
        offset += stream.read(header, maxLength: MemoryLayout<IInstruments.CoreProfileSessionTap.KDHeaderV3>.size)
        
        while (stream.hasBytesAvailable) {
            let subheader = UnsafeMutablePointer<IInstruments.CoreProfileSessionTap.KDSubHeaderV3>.allocate(capacity: 1)
            offset += stream.read(subheader, maxLength: MemoryLayout<IInstruments.CoreProfileSessionTap.KDSubHeaderV3>.size)
            
            if let tag = IInstruments.CoreProfileSessionTap.Tag(rawValue: subheader.pointee.tag) {
                let dataLen = Int(subheader.pointee.length)
                let dataP = UnsafeMutablePointer<UInt8>.allocate(capacity: dataLen)
                offset += stream.read(dataP, maxLength: dataLen)
                let subData = Data(bytes: dataP, count: dataLen)
                
                if let map = try? PropertyListSerialization.propertyList(from: subData, format: nil) as? [String : Any] {
                    print(map)
                }
                
                dataP.deallocate()
                
                if tag == .kernel || tag == .machine || tag == .config {
                    var empty: UInt8 = 0
                    while (offset < data.count && empty == 0) {
                        empty = UInt8(data[offset])
                        if empty == 0 {
                            offset += stream.read(&empty, maxLength: 1)
                        }
                    }
                }
                
                if tag == .v3RawEvents {
                    
                }
                
                if tag == .rawVersion3 || tag == .cpuEventsNull {
                    subheader.deallocate()
                    continue
                }
            }
            subheader.deallocate()
        }
        
        header.deallocate()
        stream.close()
    }
    
    private func p4(_ data: Data) {
        var entries = [IInstruments.CoreProfileSessionTap.KDEBUGEntry]()
        let stream = InputStream(data: data)
        stream.open()
        
        while stream.hasBytesAvailable {
            var entry = IInstruments.CoreProfileSessionTap.KDEBUGEntry()
            stream.read(&entry, maxLength: 64)
            entries.append(entry)
        }
        
        stream.close()
        self.delegate?.praserV4(.init(entries: entries))
    }
}
