//
//  MeasuresViewController.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 19/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class MeasuresViewController: UIViewController {

    @IBOutlet weak var scaleButton: UIButton!
    @IBOutlet weak var scaleButtonLabel: UILabel!
    
    @IBOutlet weak var emptyView: Empty!
    
    @IBOutlet weak var measuresSegmentedControl: UISegmentedControl!
    @IBOutlet weak var measuresTableView: UITableView!
    
    var weightMeasures: [Weight] = []
    var weightMeasure: Weight?
    
    var bloodPressureMeasures: [BloodPressure] = []
    var bloodPressureMeasure: BloodPressure?
    
    private func setupView() {
        
        self.scaleButtonLabel.text = "principalTitleButton".localized
        self.scaleButtonLabel.textColor = Colors.secondaryColor.color
        
        self.measuresSegmentedControl.setTitle("weightMeasuresSegmentTitle".localized, forSegmentAt: 0)
        self.measuresSegmentedControl.setTitle("bloodPressureMeasuresSegmentTitle".localized, forSegmentAt: 1)
        self.measuresSegmentedControl.tintColor = Colors.secondaryColor.color
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
        
        self.weightMeasures = DataManager.sharedInstnce.loadData(forKey: "measures") as! [Weight]
        self.bloodPressureMeasures = DataManager.sharedInstnce.loadData(forKey: "blood_pressure_measures") as! [BloodPressure]
        
        if self.weightMeasures.count == 0 &&
            self.bloodPressureMeasures.count == 0 {
            
            self.emptyView.titleLabel.text = "noMeasuresDataTitle".localized
            self.emptyView.subTitleLabel.text = "noMeasuresDataSubTitle".localized
            self.emptyView.imageView.image = UIImage(named: "no_data_list")
            self.emptyView.actionButton.isHidden = true
            
            self.measuresSegmentedControl.isHidden = true
            self.measuresTableView.isHidden = true
            self.emptyView.isHidden = false
        } else {
            
            self.measuresSegmentedControl.isHidden = false
            
            if self.weightMeasures.count > 0 &&
                self.bloodPressureMeasures.count > 0 {
                
                self.weightMeasures = self.weightMeasures.sorted(by: { $0.1.date < $0.0.date })
                self.bloodPressureMeasures = self.bloodPressureMeasures.sorted(by: { $0.1.date < $0.0.date })

                self.measuresTableView.isHidden = false
                self.emptyView.isHidden = true
            } else if self.weightMeasures.count > 0 {
                
                self.weightMeasures = self.weightMeasures.sorted(by: { $0.1.date < $0.0.date })

                self.measuresTableView.isHidden = false
                self.emptyView.isHidden = true
            } else if self.bloodPressureMeasures.count > 0 {
                
                self.bloodPressureMeasures = self.bloodPressureMeasures.sorted(by: { $0.1.date < $0.0.date })

                self.measuresTableView.isHidden = false
                self.emptyView.isHidden = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
 
    @IBAction func scaleButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func measuresSegmentedControlChanged(_ sender: Any) {
        self.measuresTableView.reloadData()
    }
}

extension MeasuresViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.measuresSegmentedControl.selectedSegmentIndex == 0 {
            
            return self.weightMeasures.count
        } else {
            
            return self.bloodPressureMeasures.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier: String?
        
        if self.measuresSegmentedControl.selectedSegmentIndex == 0 {
            
            if indexPath.row == 0 {
                identifier = "LastMeasureCell"
            } else {
                identifier = "MeasureCell"
            }
            
            guard let id = identifier else { return UITableViewCell() }
            
            let cell: MeasureTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! MeasureTableViewCell
            
            if indexPath.row == 0 {
                if self.weightMeasures.count == 1 {
                    cell.pointImageView.image = UIImage(named: "historic_one_point")
                } else {
                    cell.pointImageView.image = UIImage(named: "historic_first_point")
                }
            } else if indexPath.row == self.weightMeasures.count - 1 {
                cell.pointImageView.image = UIImage(named: "historic_last_point")
            } else {
                cell.pointImageView.image = UIImage(named: "historic_middle_point")
            }
            
            cell.measureLabel.text = self.weightMeasures[indexPath.row].value
            cell.measureUnitLabel.text = self.weightMeasures[indexPath.row].unit
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            cell.measureDateLabel.text = dateFormatter.string(from: self.weightMeasures[indexPath.row].date)
            
            return cell
        } else {
            
            if indexPath.row == 0 {
                identifier = "LastBloodPressureCell"
            } else {
                identifier = "BloodPressureCell"
            }
            
            guard let id = identifier else { return UITableViewCell() }
            
            let cell: BloodPressureMeasureTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! BloodPressureMeasureTableViewCell
            
            if indexPath.row == 0 {
                if self.bloodPressureMeasures.count == 1 {
                    cell.pointImageView.image = UIImage(named: "blood_pressure_historic_one_point")
                } else {
                    cell.pointImageView.image = UIImage(named: "blood_pressure_historic_first_point")
                }
            } else if indexPath.row == self.bloodPressureMeasures.count - 1 {
                cell.pointImageView.image = UIImage(named: "blood_pressure_historic_last_point")
            } else {
                cell.pointImageView.image = UIImage(named: "blood_pressure_historic_middle_point")
            }
            
            cell.bloodPressureMeasureLabel.text = self.bloodPressureMeasures[indexPath.row].pressureValue
            cell.bloodPressureMeasureUnitLabel.text = self.bloodPressureMeasures[indexPath.row].pressureUnit
            cell.heartMeasureLabel.text = self.bloodPressureMeasures[indexPath.row].heartValue
            cell.heartMeasureUnitLabel.text = self.bloodPressureMeasures[indexPath.row].heartUnit
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            cell.measureDateLabel.text = dateFormatter.string(from: self.bloodPressureMeasures[indexPath.row].date)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 132
        } else {
            return 88
        }
    }
}

extension MeasuresViewController {
    
    func manageMeasureData(_ notification: Notification) {
        
        guard let measureData = notification.userInfo,
            let measureType = measureData["type"] as? WeightMeasureType else { return }
        
        if measureType == .Sync {
            
            guard let measuresDataSyncArray = measureData["measures"] as? Array<Dictionary<String, Any>> else { return }
            
            for measureDataSync in measuresDataSyncArray {
                
                guard let weight = measureDataSync["weight"] as? Float,
                    let date = measureDataSync["date"] as? Date else { continue }
                
                let newMeasure = Weight(value: String(describing: weight),
                                         unit: "Kg",
                                         date: date)
                
                Measure.saveMeasure(newMeasure)
            }
        } else if measureType == .Scale {
            
            if let measureDataScaleArray = measureData["measure"] as? Dictionary<String, Any> {
                
                if let stable = measureDataScaleArray["stable"] as? Bool,
                    let weight = measureDataScaleArray["weight"] as? Float {
                    
                    if stable {
                        self.weightMeasure = Weight(value: String(describing: weight), unit: "Kg", date: Date())
                    } else {
                        
                        let measureViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MeasureViewController") as! MeasureViewController
                        self.present(measureViewController, animated: true, completion: nil)
                    }
                }
            } else if let status = measureData["status"] as? Bool {
                
                if status {
                    HS4Manager.sharedInstance.startMeasureInBackground(HSUnit(rawValue: 1))
                } else {
                    print("Error: \(measureData["error"])")
                }
            }
        }
    }
}
