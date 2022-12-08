//
//  MobileManager.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/24.
//

import Cocoa
import LibMobileDevice

class MobileManager: NSObject {
    public static var share: MobileManager = {
        let device = MobileManager()
        device.subscribe()
        return device
    }()
        
    public private(set) var deviceList: [DeviceItem] = []
    private var context_t: idevice_subscription_context_t? = nil
    
    private func subscribe() {
        idevice_event_subscribe({ _, _ in
            NotificationCenter.default.post(name: MobileManager.subscribeChangedNotification, object: nil)
        }, nil)
    }
}

// MARK: - Public -
extension MobileManager {
    func refreshDeviceList() {
        var devices = [DeviceItem]()

        let listPoint = UnsafeMutablePointer<UnsafeMutablePointer<idevice_info_t?>?>.allocate(capacity: 1)
        let count = UnsafeMutablePointer<Int32>.allocate(capacity: 1)

        idevice_get_device_list_extended(listPoint, count)

        let len = Int(count.pointee)
        let list = listPoint.pointee

        (0 ..< len).forEach { i in
            if let device = list?[i]?.pointee,
               let udid = StringLiteralType(utf8String: device.udid) {
                let item = DeviceItem(udid: udid, type: device.conn_type == CONNECTION_USBMUXD ? .usb : .net)
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

// MARK: - Notification Name -
extension MobileManager {
    public static let subscribeChangedNotification = NSNotification.Name("Mobile_Subscribe_Changed_Notification")
}
