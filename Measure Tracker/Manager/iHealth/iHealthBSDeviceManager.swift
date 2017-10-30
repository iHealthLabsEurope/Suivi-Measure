//
//  iHealthBSDeviceManager.swift
//  Measure Tracker
//
//  Created by Gustavo Serra on 27/10/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

protocol iHealthBSDeviceDelegate: class {
    func deviceConnected(_ userInfo: Dictionary<AnyHashable, Any>?)
    func deviceDisconnected(_ userInfo: Dictionary<AnyHashable, Any>?)
}

protocol iHealthBSDevice {
    
    var name: String { get set }
    var type: HealthDeviceType { get set }
    var connectEventName: String { get set }
    var disconnectEventName: String { get set }
}

class iHealthBSDeviceManager: NSObject, iHealthBSDevice {
    
    var name: String
    var type: HealthDeviceType
    var connectEventName: String
    var disconnectEventName: String
    
    weak var delegate: iHealthBSDeviceDelegate?
    
    // MARK: - Init Methods
    
    init(_ name: String, type: HealthDeviceType, connectEvent: String, disconnectEvent: String) {
        
        self.name = name
        self.type = type
        self.connectEventName = connectEvent
        self.disconnectEventName = disconnectEvent

        super.init()
        
        self.registerObserver(self.connectEventName, selector: #selector(iHealthBSDeviceManager.deviceConnectedListener(_:)))
        self.registerObserver(self.disconnectEventName, selector: #selector(iHealthBSDeviceManager.deviceDisconnectedListener(_:)))
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
    
    func deviceConnectedListener(_ notification: Notification) -> Void {
        print("Device Connected: \(notification)")
        self.delegate?.deviceConnected(notification.userInfo)
    }
    
    func deviceDisconnectedListener(_ notification: Notification) -> Void {
        print("Device Disconnected: \(notification)")
        self.delegate?.deviceDisconnected(notification.userInfo)
    }
}
