//
//  ALockAction.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/12.
//

import AppKit

class ALockAction<I : ILockdownProtocol> {
    private(set) var lockdown: ILockdown? = nil
    private(set) var instance: I? = nil
    
    public func clean() {
        lockdown = nil
        instance = nil
    }
    
    public func build(_ device: IDevice) -> Bool {
        clean()
        if let lockdown = ILockdown(device),
           let instance = I(device, lockdown) {
            self.lockdown = lockdown
            self.instance = instance
            return true
        }
        return false
    }
}
