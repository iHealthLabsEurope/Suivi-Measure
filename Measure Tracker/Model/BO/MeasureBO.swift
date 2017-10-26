//
//  MeasureBO.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 18/10/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

final class MeasureBO {
    
    static func saveMeasure(_ measure: Measure?) {
        
        if let newMeasure = measure {
            
            var measures = DataManager.sharedInstnce.loadData(forKey: "measures") as? [Measure]
            
            if let _ = measures {
                
                measures?.append(newMeasure)
            } else {
                
                measures = [newMeasure]
            }
            
            DataManager.sharedInstnce.saveData(item: measures! as NSCoding, forKey: "measures")
        } else {
            
            
        }
    }
}
