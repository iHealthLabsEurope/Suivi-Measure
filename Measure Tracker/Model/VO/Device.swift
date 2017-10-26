//
//  Device.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 20/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

enum DeviceStatus {
    case unknown
    case discovering
    case discovered
    case disconnecting
    case disconnected
    case connecting
    case connected
    case measuring
    case measured
    case syncing
    case synced
    case syncedNoData
}

struct Device {
    
    var name: String?
    var type: HealthDeviceType?
    var status: DeviceStatus?
    var macAddress: String?
    
    init() {
        
        self.status = .unknown
    }
    
    init(_ macAddress: String) {
        
        self.macAddress = macAddress
        self.status = .disconnected
    }
}
