//
//  MeasureGuideViewController.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 19/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class MeasureViewController: UIViewController {

    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var instructionImageView: UIImageView!
    
    @IBOutlet weak var measureStackView: UIStackView!
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var measureUnitLabel: UILabel!
    
    var measure: Weight?
    
    func setupView() {

        self.measureLabel.textColor = Colors.primaryColor.color
        self.measureUnitLabel.textColor = Colors.textColor.color
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.manageMeasureData(_:)),
                                               name: NSNotification.Name("MeasureData"),
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
 
    @IBAction func exitButtonClicked(_ sender: Any) {
        
        HS4Manager.sharedInstance.startMeasureInBackground(HSUnit(rawValue: 1))
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension MeasureViewController {
    
    func manageMeasureData(_ notification: Notification) {
        
        guard let measureData = notification.userInfo,
            let measureType = measureData["type"] as? WeightMeasureType else { return }
        
        if measureType == .Scale {
            
            if let measureDataScaleArray = measureData["measure"] as? Dictionary<String, Any> {
                
                if let stable = measureDataScaleArray["stable"] as? Bool,
                    let weight = measureDataScaleArray["weight"] as? Float {
                    
                    self.measureLabel.text = String(describing: weight)
                    
                    if stable {
                        self.measure = Weight(value: String(describing: weight), unit: "Kg", date: Date())
                    }
                }
            } else if let status = measureData["status"] as? Bool {
                
                if status {
                    Measure.saveMeasure(self.measure)
                } else {
                    print("Error: \(measureData["error"])")
                }
            }
        }
    }
}
