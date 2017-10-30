//
//  BG5Manager.swift
//  Measure Tracker
//
//  Created by Gustavo Serra on 27/10/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

typealias iHealthBP5Pressure = (Double) -> Void
typealias iHealthBP5MeasureResult = (Bool, Dictionary<AnyHashable, Any>?, BPDeviceError?) -> Void
typealias iHealthBP5StopMeasureResult = (Bool, BPDeviceError?) -> Void

final class BP5Manager: iHealthBSDeviceManager {
    
    // MARK: - Sigleton
    
    static let sharedInstance: BP5Manager = {
        
        let instance = BP5Manager("BP5",
                                  type: HealthDeviceType._BP5,
                                  connectEvent: BP5ConnectNoti,
                                  disconnectEvent: BP5DisConnectNoti)
        
        return instance
    }()

    // MARK: - Device Methods
    
    func allDevices() -> Array<BP5> {
        return BP5Controller.share().getAllCurrentBP5Instace() as! [BP5]
    }
    
    func searchDevice(_ macAddress: String) -> BP5? {
        return self.allDevices().first { return $0.serialNumber == macAddress }
    }
    
    func startMeasure(_ pressure: @escaping iHealthBP5Pressure, result: @escaping iHealthBP5MeasureResult) {
        
        guard let device = self.allDevices().first else {
            result(false, nil, BPDeviceError.didDisconnect)
            return
        }
        
        device.commandStartMeasure(zeroingState: { (isCompleted) in
            
        }, pressure: { (pressureDataArray) in
            pressure((pressureDataArray?.first as? Double)!)
        }, waveletWithHeartbeat: { (waveHBDataArray) in
            
        }, waveletWithoutHeartbeat: { (waveDataArray) in
            
        }, result: { (resultDataDictionary) in
            result(true, resultDataDictionary, nil)
        }) { (error) in
            result(false, nil, error)
        }
    }
    
    func stopMeasure(_ result: @escaping iHealthBP5StopMeasureResult) {
        
        guard let device = self.allDevices().first else {
            result(false, BPDeviceError.didDisconnect)
            return
        }
        
        device.stopBPMeassureSuccessBlock({
            result(true, nil)
        }) { (error) in
            result(false, error)
        }
    }
}
