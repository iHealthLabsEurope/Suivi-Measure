//
//  DataManager.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 22/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import Foundation

class DataManager {
    
    static let sharedInstnce = DataManager()
    
    private init() {}
    
    private var filePath: String {
        
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return (url!.appendingPathComponent("Data").path)
    }
    
    func saveData(item: NSCoding, forKey: String) {
        
        if var storedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Dictionary<String, Any> {
            
            storedData[forKey] = item
            
            NSKeyedArchiver.archiveRootObject(storedData, toFile: filePath)
        } else {
            
            NSKeyedArchiver.archiveRootObject([forKey:item], toFile: filePath)
        }
    }
    
    func loadData(forKey: String) -> NSCoding {

        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Dictionary<String, Any>,
            let ourKeyData = ourData[forKey] as? NSCoding {
            
            return ourKeyData
        }
        
        return [] as NSCoding
    }
}
