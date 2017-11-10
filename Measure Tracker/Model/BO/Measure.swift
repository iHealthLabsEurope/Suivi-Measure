//
//  Measure.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 18/10/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

protocol MeasureDelegate: class {
    func measureFinished(type: MeasureType)
}

enum MeasureType: String {
    case Weight
    case BloodPressure
}

final class Measure {
    
    static func saveMeasure(_ measure: Weight?) {
        
        if let newMeasure = measure {
            
            var measures = DataManager.sharedInstnce.loadData(forKey: "measures") as? [Weight]
            
            if let _ = measures {
                
                measures?.append(newMeasure)
            } else {
                
                measures = [newMeasure]
            }
            
            DataManager.sharedInstnce.saveData(item: measures! as NSCoding, forKey: "measures")
        } else {
            
            
        }
    }
    
    static func saveMeasure(_ measure: BloodPressure?) {
        
        if let newMeasure = measure {
            
            var measures = DataManager.sharedInstnce.loadData(forKey: "blood_pressure_measures") as? [BloodPressure]
            
            if let _ = measures {
                
                measures?.append(newMeasure)
            } else {
                
                measures = [newMeasure]
            }
            
            DataManager.sharedInstnce.saveData(item: measures! as NSCoding, forKey: "blood_pressure_measures")
        } else {
            
            
        }
    }
}
