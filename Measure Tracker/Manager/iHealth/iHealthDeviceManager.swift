//
//  iHealthDeviceManager.swift
//  Nurse
//
//  Created by Gustavo Serra on 14/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

protocol iHealthDeviceDelegate: class {
    func deviceDiscovered(_ userInfo: Dictionary<AnyHashable, Any>?)
    func deviceConnected(_ userInfo: Dictionary<AnyHashable, Any>?)
    func deviceDisconnected(_ userInfo: Dictionary<AnyHashable, Any>?)
    func deviceConnectFailed(_ userInfo: Dictionary<AnyHashable, Any>?)
}

protocol iHealthDevice {
    
    var name: String { get set }
    var type: HealthDeviceType { get set }
    var discoveryEventName: String { get set }
}

class iHealthDeviceManager: NSObject, iHealthDevice {
    
    var name: String
    var type: HealthDeviceType
    var discoveryEventName: String
    
    weak var delegate: iHealthDeviceDelegate?
    
    // MARK: - Init Methods
    
    init(_ name: String, type: HealthDeviceType, event: String) {
        
        self.name = name
        self.type = type
        self.discoveryEventName = event
        
        super.init()
    }
    
    deinit {
        self.delegate = nil
    }
    
    // MARK: - Observer Methods
    
    func registerObserver(_ eventName: String, selector: Selector) -> Void {
        
        self.unregisterObserver(eventName)
        
        NotificationCenter.default.addObserver(self,
                                               selector: selector,
                                               name: Notification.Name(eventName),
                                               object: nil)
    }
    
    func unregisterObserver(_ eventName: String) -> Void {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name(eventName),
                                                  object: nil)
    }
    
    // MARK: - Listener Methods
    
    func deviceDiscoveredListener(_ notification: Notification) -> Void {
        print("Device Discovered: \(notification)")
        self.delegate?.deviceDiscovered(notification.userInfo)
    }
    
    func deviceConnectedListener(_ notification: Notification) -> Void {
        print("Device Connected: \(notification)")
        self.delegate?.deviceConnected(notification.userInfo)
    }
    
    func deviceDisconnectedListener(_ notification: Notification) -> Void {
        print("Device Disconnected: \(notification)")
        self.delegate?.deviceDisconnected(notification.userInfo)
    }
    
    func deviceFailedToConnectListener(_ notification: Notification) -> Void {
        print("Device Failed to Listen: \(notification)")
        self.delegate?.deviceConnectFailed(notification.userInfo)
    }
    
    // MARK: - Discovery Methods
    
    func startDiscovery() -> Void {
        
        self.registerObserver(self.discoveryEventName, selector: #selector(iHealthDeviceManager.deviceDiscoveredListener(_:)))
        
        ScanDeviceController.commandGetInstance().commandScanDeviceType(self.type)
    }
    
    func stopDiscovery() -> Void {
        
        self.unregisterObserver(self.discoveryEventName)
        
        ScanDeviceController.commandGetInstance().commandStopScanDeviceType(self.type)
    }
}
