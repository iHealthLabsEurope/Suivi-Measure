//
//  Weight.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 21/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

//enum BloodPressureMeasureType: String {
//    case Scale
//    case Sync
//
//    var title: String {
//        
//        switch self {
//        case .Scale:
//            return "measureTypeScale".localized
//        case .Sync:
//            return "measureTypeSync".localized
//        }
//    }
//}

class BloodPressure: NSObject, NSCoding  {
    
    struct Keys {
        static let pressureValue = "pressure_value"
        static let pressureUnit = "pressure_unit"
        static let heartValue = "heart_value"
        static let heartUnit = "heart_unit"
        static let date = "date"
    }
    
    private var _pressureValue = ""
    private var _pressureUnit = ""
    private var _heartValue = ""
    private var _heartUnit = ""
    private var _date = Date()
    
    override init() {}
    
    init(pressureValue: String, pressureUnit: String, heartValue: String, heartUnit: String, date: Date) {
        self._pressureValue = pressureValue
        self._pressureUnit = pressureUnit
        self._heartValue = heartValue
        self._heartUnit = heartUnit
        self._date = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        if let pressureValueObject = aDecoder.decodeObject(forKey: Keys.pressureValue) as? String,
            let pressureUnitObject = aDecoder.decodeObject(forKey: Keys.pressureUnit) as? String,
            let heartValueObject = aDecoder.decodeObject(forKey: Keys.heartValue) as? String,
            let heartUnitObject = aDecoder.decodeObject(forKey: Keys.heartUnit) as? String,
            let dateObject = aDecoder.decodeObject(forKey: Keys.date) as? Date {
            
            _pressureValue = pressureValueObject
            _pressureUnit = pressureUnitObject
            _heartValue = heartValueObject
            _heartUnit = heartUnitObject
            _date = dateObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(_pressureValue, forKey: Keys.pressureValue)
        aCoder.encode(_pressureUnit, forKey: Keys.pressureUnit)
        aCoder.encode(_heartValue, forKey: Keys.heartValue)
        aCoder.encode(_heartUnit, forKey: Keys.heartUnit)
        aCoder.encode(_date, forKey: Keys.date)
    }
    
    var pressureValue: String {
        get {
            return _pressureValue
        }
        set {
            _pressureValue = newValue
        }
    }
    
    var pressureUnit: String {
        get {
            return _pressureUnit
        }
        set {
            _pressureUnit = newValue
        }
    }
    
    var heartValue: String {
        get {
            return _heartValue
        }
        set {
            _heartValue = newValue
        }
    }
    
    var heartUnit: String {
        get {
            return _heartUnit
        }
        set {
            _heartUnit = newValue
        }
    }
    
    var date: Date {
        get {
            return _date
        }
        set {
            _date = newValue
        }
    }
}


