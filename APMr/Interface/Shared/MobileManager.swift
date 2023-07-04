//
//  MobileManager.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/24.
//

import Cocoa
import LibMobileDevice

class MobileManager {
    static var share = MobileManager()
        
    public private(set) var deviceList: [IDevice.P] = []
    private var context_t: idevice_subscription_context_t? = nil
        
    init() {
        idevice_event_subscribe({ _, _ in
            MobileManager.share.refreshDeviceList()
            NotificationCenter.default.post(name: MobileManager.subscribeChangedNotification, object: nil)
        }, nil)
    }
}

// MARK: - Public 
extension MobileManager {
    func refreshDeviceList() {
        var devices = [IDevice.P]()

        let listPoint = UnsafeMutablePointer<UnsafeMutablePointer<idevice_info_t?>?>.allocate(capacity: 1)
        let count = UnsafeMutablePointer<Int32>.allocate(capacity: 1)

        idevice_get_device_list_extended(listPoint, count)

        let len = Int(count.pointee)
        let list = listPoint.pointee

        (0 ..< len).forEach { i in
            if let device = list?[i]?.pointee,
               let udid = StringLiteralType(utf8String: device.udid) {
                let item = IDevice.P(udid: udid, type: device.conn_type == CONNECTION_USBMUXD ? .usb : .net)
                devices.append(item)
            }
        }

        if let list = list {
            idevice_device_list_extended_free(list)
        }

        deviceList = devices

        listPoint.deallocate()
        count.deallocate()
    }
}

// MARK: - Notification Name
extension MobileManager {
    public static let subscribeChangedNotification = NSNotification.Name("Mobile_Subscribe_Changed_Notification")
}
