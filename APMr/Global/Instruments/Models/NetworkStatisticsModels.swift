//
//  IInstrumentsNetworkStatisticsModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/28.
//

import ObjectMapper

extension IInstruments.NetworkStatistics {
    struct Model: Mappable {
        var net_bytes: Int64 = 0
        var net_bytes_delta: Int64 = 0
        var net_packets: Int64 = 0
        var net_packets_delta: Int64 = 0
        var net_rx_bytes: Int64 = 0
        var net_rx_bytes_delta: Int64 = 0
        var net_rx_packets: Int64 = 0
        var net_rx_packets_delta: Int64 = 0
        var net_tx_bytes: Int64 = 0
        var net_tx_bytes_delta: Int64 = 0
        var net_tx_packets: Int64 = 0
        var net_tx_packets_delta: Int64 = 0
        var net_connections: [IInstruments.NetworkStatistics.ConnectItem]? = nil
        var pid: Int64 = 0
        var time: Date?
        
        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            net_bytes            <- map["net.bytes", nested: false]
            net_bytes_delta      <- map["net.bytes.delta", nested: false]
            net_packets          <- map["net.packets", nested: false]
            net_packets_delta    <- map["net.packets.delta", nested: false]
            net_rx_bytes         <- map["net.rx.bytes", nested: false]
            net_rx_bytes_delta   <- map["net.rx.bytes.delta", nested: false]
            net_rx_packets       <- map["net.rx.packets", nested: false]
            net_rx_packets_delta <- map["net.rx.packets.delta", nested: false]
            net_tx_bytes         <- map["net.tx.bytes", nested: false]
            net_tx_bytes_delta   <- map["net.tx.bytes.delta", nested: false]
            net_tx_packets       <- map["net.tx.packets", nested: false]
            net_tx_packets_delta <- map["net.tx.packets.delta", nested: false]
            net_connections      <- map["net.connections[]", nested: false]
            pid                  <- map["pid"]
            time                 <- map["time"]
        }
    }

    struct ConnectItem: Mappable {
        var Int64erface: String?
        var localAddr: String?
        var localPort: String?
        var protocols: String?
        var remoteAddr: String?
        var remotePort: String?
        var rxBytes: Int64 = 0
        var rxBytesDelta: Int64 = 0
        var rxPackets: Int64 = 0
        var rxPacketsDelta: Int64 = 0
        var state: String?
        var txBytes: Int64 = 0
        var txBytesDelta: Int64 = 0
        var txPackets: Int64 = 0
        var txPacketsDelta: Int64 = 0
        
        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            Int64erface      <- map["Int64erface"]
            localAddr      <- map["localAddr"]
            localPort      <- map["localPort"]
            protocols      <- map["protocol"]
            remoteAddr     <- map["remoteAddr"]
            remotePort     <- map["remotePort"]
            rxBytes        <- map["rxBytes"]
            rxBytesDelta   <- map["rxBytesDelta"]
            rxPackets      <- map["rxPackets"]
            rxPacketsDelta <- map["rxPacketsDelta"]
            state          <- map["state"]
            txBytes        <- map["txBytes"]
            txBytesDelta   <- map["txBytesDelta"]
            txPackets      <- map["txPackets"]
            txPacketsDelta <- map["txPacketsDelta"]
        }
    }
}
 


