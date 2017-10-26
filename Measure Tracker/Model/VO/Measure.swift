//
//  Measure.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 21/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

enum MeasureType: String {
    case Scale
    case Sync
    
    var title: String {
        
        switch self {
        case .Scale:
            return "measureTypeScale".localized
        case .Sync:
            return "measureTypeSync".localized
        }
    }
}

class Measure: NSObject, NSCoding  {
    
    struct Keys {
        static let value = "value"
        static let unit = "unit"
        static let date = "date"
    }
    
    private var _value = ""
    private var _unit = ""
    private var _date = Date()
    
    override init() {}
    
    init(value: String, unit: String, date: Date) {
        self._value = value
        self._unit = unit
        self._date = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        if let valueObject = aDecoder.decodeObject(forKey: Keys.value) as? String,
            let unitObject = aDecoder.decodeObject(forKey: Keys.unit) as? String,
            let dateObject = aDecoder.decodeObject(forKey: Keys.date) as? Date {
            
            _value = valueObject
            _unit = unitObject
            _date = dateObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(_value, forKey: Keys.value)
        aCoder.encode(_unit, forKey: Keys.unit)
        aCoder.encode(_date, forKey: Keys.date)
    }
    
    var value: String {
        get {
            return _value
        }
        set {
            _value = newValue
        }
    }
    
    var unit: String {
        get {
            return _unit
        }
        set {
            _unit = newValue
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
