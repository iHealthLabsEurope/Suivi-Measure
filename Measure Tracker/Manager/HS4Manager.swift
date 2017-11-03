//
//  HS4Manager.swift
//  Nurse
//
//  Created by Gustavo Serra on 15/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

typealias iHealthHS4MeasureResult = (Dictionary<String, Any>) -> Void
typealias iHealthHS4SyncResult = (Array<Dictionary<String, Any>>) -> Void
typealias iHealthHS4Completion = (Bool, HS4DeviceError?) -> Void

final class HS4Manager: iHealthDeviceManager {

    private var isMeasuring: Bool = false
    
    private var modeBackground: Bool = false
    private var autoConnected: Bool = true
    private var isConnected: Bool = false {
        
        didSet {
            
            if !self.isConnected && self.autoConnected {
                
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.discoveryInBackground), userInfo: nil, repeats: false)
            }
        }
    }

    // MARK: - Sigleton
    
    static let sharedInstance: HS4Manager = {
        
        let instance = HS4Manager("HS4",
                                         type: HealthDeviceType._HS4,
                                         event: HS4Discover)
        
        return instance
    }()
    
    // MARK: - Override Methods

    override init(_ name: String, type: HealthDeviceType, event: String) {
        
        super.init(name, type: type, event: event)
        
        HS4Controller.shareIHHs4()
    }
    
    // MARK: - Device Methods
    
    func allDevices() -> Array<HS4> {
        return HS4Controller.shareIHHs4().getAllCurrentHS4Instace() as! [HS4]
    }
    
    func searchDevice(_ macAddress: String) -> HS4? {
        return self.allDevices().first { return $0.deviceID == macAddress }
    }
    
    func connectDevice(_ macAddress: String) -> Void {
        
        self.registerObserver(HS4ConnectNoti, selector: #selector(iHealthDeviceManager.deviceConnectedListener(_:)))
        self.registerObserver(HS4DisConnectNoti, selector: #selector(iHealthDeviceManager.deviceDisconnectedListener(_:)))
        self.registerObserver(HS4ConnectFailed, selector: #selector(iHealthDeviceManager.deviceFailedToConnectListener(_:)))
        
        ConnectDeviceController.commandGetInstance().commandContectDevice(with: self.type, andSerialNub: macAddress)
    }
    
    func disconnectDevice(_ macAddress: String) -> Void {
        
        guard let device = self.searchDevice(macAddress) else { return }
        
        device.commandDisconnectDevice()
    }
    
    func disconnectDevice() {
        
        guard let device = self.allDevices().first else { return }
        
        self.autoConnected = false
        
        device.commandEndCurrentConnection({ (status) in
            print("Status: \(status)")
        }) { (error) in
            print("Error: \(error)")
        }

        device.commandDisconnectDevice()
    }
    
    func stopCurrentMeasure() {
        
        guard let device = self.allDevices().first else { return }
        
        device.commandEndCurrentConnection({ (status) in
            print("Status: \(status)")
        }) { (error) in
            print("Error: \(error)")
        }
    }
    
    func startMeasure(_ unit: HSUnit, result: @escaping iHealthHS4MeasureResult, complete: @escaping iHealthHS4Completion) -> Void {
        
        guard let device = self.allDevices().first else {
            if self.isMeasuring {
                complete(false, HS4DeviceError.deviceDisconnect)
            }
            return
        }
        
        self.isMeasuring = true
        
        device.commandMeasure(withUint: unit, weight: { [unowned self] (unStableWeight) in
            
            if self.isMeasuring {
                
                result(["weight": unStableWeight?.floatValue,
                        "stable": false])
            }
        }, stableWeight: { [unowned self] (stableWeightDic) in
                
            if self.isMeasuring {
                
                result(["weight": stableWeightDic?["Weight"],
                        "stable": true])
                
                self.isMeasuring = false
                
                complete(true, nil)
            }
        }, disposeErrorBlock: { [unowned self] (error) in
                
            if self.isMeasuring {
                
                complete(false, error)
            }
        })
    }
    
    func startSync(_ result: @escaping iHealthHS4SyncResult, complete: @escaping iHealthHS4Completion) -> Void {
        
        guard let device = self.allDevices().first else {
            complete(false, HS4DeviceError.deviceDisconnect)
            return
        }
        
        device.commandTransferMemorryData({ (startDataDictionary) in
            
        }, disposeProgress: { (progress) in
            
        }, memorryData: { (historyDataArray) in
            
            if let measures = historyDataArray as? Array<Dictionary<String, Any>> {
                result(measures)
            }
        }, finishTransmission: {
            
            complete(true, nil)
        }, disposeErrorBlock: { (error) in
            
            complete(false, error)
        })
    }
    
    func discoveryInBackground() {
        
        self.modeBackground = true
        self.autoConnected = true
        
        self.startDiscovery()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            
            self.stopDiscovery()
            
            if !self.isConnected {
                
                Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.discoveryInBackground), userInfo: nil, repeats: false)
            }
        }
    }
    
    func startMeasureInBackground(_ unit: HSUnit) {
        
        self.stopCurrentMeasure()
        
        self.startSync({ (measuresDataArray) in

            if measuresDataArray.count > 0 {
                print("------------ SyncData ---------------")
                NotificationCenter.default.post(name: NSNotification.Name("MeasureData"),
                                            object: nil,
                                            userInfo: ["type" : WeightMeasureType.Sync,
                                                       "measures" : measuresDataArray])
            }
        }, complete: { [weak self] (status, error) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.startMeasure(unit, result: { (measureDataDic) in
                
                if let weight = measureDataDic["weight"] as? Float {
                    
                    if weight > 0 {
                        print("------------ MeasureData ---------------")
                        NotificationCenter.default.post(name: NSNotification.Name("MeasureData"),
                                                        object: nil,
                                                        userInfo: ["type" : WeightMeasureType.Scale,
                                                                   "measure" : measureDataDic])
                    }
                }
                
            }, complete: { (status, error) in
                
                print("------------ MeasureData Finish ---------------")
                NotificationCenter.default.post(name: NSNotification.Name("MeasureData"),
                                                object: nil,
                                                userInfo: ["type" : WeightMeasureType.Scale,
                                                           "status" : status,
                                                           "error" : error])
            })
        })
    }
    
    override func deviceDiscoveredListener(_ notification: Notification) {
        super.deviceDiscoveredListener(notification)
        
        if self.modeBackground {
            
            let userInfo = notification.userInfo
            guard let macAddr = userInfo?["SerialNumber"] as? String ?? userInfo?["ID"] as? String else { return }
            
            self.connectDevice(macAddr)
        }
    }
    
    override func deviceConnectedListener(_ notification: Notification) {
        super.deviceConnectedListener(notification)
        
        if self.modeBackground {
            
            self.isConnected = true
            
            self.startMeasureInBackground(HSUnit(rawValue: 1))
        }
    }
    
    override func deviceDisconnectedListener(_ notification: Notification) {
        super.deviceDisconnectedListener(notification)
        
        if self.modeBackground {
            
            self.isConnected = false
        }
    }
}
