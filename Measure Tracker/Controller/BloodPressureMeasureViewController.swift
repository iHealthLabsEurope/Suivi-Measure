//
//  BloodPressureMeasureViewController.swift
//  Measure Tracker
//
//  Created by Gustavo Serra on 06/11/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class BloodPressureMeasureViewController: UIViewController {
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var bloodPressureMeasuringStackView: UIStackView!
    @IBOutlet weak var bloodPressureMeasuringLabel: UILabel!
    @IBOutlet weak var bloodPressureMeasuringUnitLabel: UILabel!
    
    @IBOutlet weak var stopMeasureButton: UIButton!
    
    @IBOutlet weak var measureStackView: UIStackView!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var bloodPressureUnitLabel: UILabel!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var heartUnitLabel: UILabel!
    
    var isMeasuring: Bool = true {
        
        didSet {
            
            if self.isMeasuring {
                
                self.bloodPressureMeasuringLabel.text = "0"
                
                self.measureStackView.isHidden = true
                self.bloodPressureMeasuringStackView.isHidden = false
                
                self.stopMeasureButton.setTitle("stopMeasureTitleButton".localized, for: .normal)
                self.stopMeasureButton.setTitleColor(Colors.dangerColor.color, for: .normal)
                self.stopMeasureButton.backgroundColor = Colors.backgroundColor.color
            } else {
                
                self.measureStackView.isHidden = false
                self.bloodPressureMeasuringStackView.isHidden = true
                
                self.stopMeasureButton.setTitle("restartMeasureTitleButton".localized, for: .normal)
                self.stopMeasureButton.setTitleColor(Colors.secondaryColor.color, for: .normal)
                self.stopMeasureButton.backgroundColor = Colors.backgroundColor.color
            }
        }
    }
    
    private func setupView() {
        
        self.bloodPressureMeasuringLabel.textColor = Colors.tertiaryColor.color
        self.bloodPressureMeasuringUnitLabel.textColor = Colors.textColor.color
        
        self.stopMeasureButton.setTitle("stopMeasureTitleButton".localized, for: .normal)
        self.stopMeasureButton.setTitleColor(Colors.dangerColor.color, for: .normal)
        self.stopMeasureButton.backgroundColor = Colors.backgroundColor.color
        
        self.measureStackView.isHidden = true
        self.bloodPressureLabel.textColor = Colors.tertiaryColor.color
        self.bloodPressureUnitLabel.textColor = Colors.textColor.color
        self.heartLabel.textColor = Colors.tertiaryColor.color
        self.heartUnitLabel.textColor = Colors.textColor.color
    }
    
    private func startMeasure() {
        
        self.isMeasuring = true
        
        BP5Manager.sharedInstance.startMeasure({ (pressure) in
            
            self.bloodPressureMeasuringLabel.text = "\(Int(pressure))"
            
        }) { (status, measureData, error) in
            
            self.isMeasuring = false
            
            if status {
                
                guard let sys = measureData?["sys"] as? Int,
                    let dia = measureData?["dia"] as? Int,
                    let heart = measureData?["heartRate"] as? Int else { return }
                
                let newBloodPressure = BloodPressure(pressureValue: "\(sys)/\(dia)",
                    pressureUnit: "mmHg",
                    heartValue: "\(heart)",
                    heartUnit: "Pouls",
                    date: Date())
                
                Measure.saveMeasure(newBloodPressure)
                
                self.bloodPressureLabel.text = newBloodPressure.pressureValue
                self.bloodPressureUnitLabel.text = newBloodPressure.pressureUnit
                self.heartLabel.text = newBloodPressure.heartValue
                self.heartUnitLabel.text = newBloodPressure.heartUnit
            } else {
                
                print(error.debugDescription)
                
                if error == BPDeviceError.didDisconnect {
                    
                    let alert = UIAlertController(title: "deviceTurnOffMessage".localized, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "deviceTurnOffMessageOkButton".localized, style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                } else if error == BPDeviceError.error4 {
                    
                    let alert = UIAlertController(title: "deviceNotTightTitle".localized, message: "deviceNotTightMessage".localized, preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "deviceNotTightMessageOkButton".localized, style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()

        self.startMeasure()
    }
    
    @IBAction func exitButtonClicked(_ sender: Any) {
        
        if isMeasuring {
            
            BP5Manager.sharedInstance.stopMeasure { (status, error) in
                
                print(error.debugDescription)
                
                self.isMeasuring = false
                
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func stopMeasureButtonClicked(_ sender: Any) {
        
        if isMeasuring {
            
            BP5Manager.sharedInstance.stopMeasure { (status, error) in
                
                print(error.debugDescription)
                
                self.isMeasuring = false
            }
        } else {
            
            self.startMeasure()
        }
    }
}
