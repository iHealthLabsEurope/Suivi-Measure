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
    
    @IBOutlet weak var measuresTableView: UITableView!
    
    var measures: [Measure] = []
    var measure: Measure?
    
    private func setupView() {
        
        self.scaleButtonLabel.text = "scaleTitleButton".localized
        self.scaleButtonLabel.textColor = Colors.secondaryColor.color
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
        
        if let measuresLoaded = DataManager.sharedInstnce.loadData(forKey: "measures") as? [Measure],
            measuresLoaded.count > 0 {
            
            self.emptyView.isHidden = true
            
            self.measures = measuresLoaded.sorted(by: { $0.1.date < $0.0.date })
            
            self.measuresTableView.reloadData()
        } else {
            
            self.emptyView.titleLabel.text = "noMeasuresDataTitle".localized
            self.emptyView.subTitleLabel.text = "noMeasuresDataSubTitle".localized
            self.emptyView.imageView.image = UIImage(named: "no_data_list")
            self.emptyView.actionButton.isHidden = true
            
            self.emptyView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
 
    @IBAction func scaleButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
}

extension MeasuresViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.measures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier: String?
        
        if indexPath.row == 0 {
            identifier = "LastMeasureCell"
        } else {
            identifier = "MeasureCell"
        }
        
        guard let id = identifier else { return UITableViewCell() }
        
        let cell: MeasureTableViewCell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! MeasureTableViewCell
        
        if indexPath.row == 0 {
            if self.measures.count == 1 {
                cell.pointImageView.image = UIImage(named: "historic_one_point")
            } else {
                cell.pointImageView.image = UIImage(named: "historic_first_point")
            }
        } else if indexPath.row == self.measures.count - 1 {
            cell.pointImageView.image = UIImage(named: "historic_last_point")
        } else {
            cell.pointImageView.image = UIImage(named: "historic_middle_point")
        }

        cell.measureLabel.text = self.measures[indexPath.row].value
        cell.measureUnitLabel.text = self.measures[indexPath.row].unit
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        cell.measureDateLabel.text = dateFormatter.string(from: self.measures[indexPath.row].date)
        
        if indexPath.row == 0 {
            
            if let lastMeasure = Float(self.measures[indexPath.row].value),
                let firstValue = self.measures.last?.value,
                let firstMeasure = Float(firstValue) {
                
                cell.measureDifferenceLabel.text = "+ \(Double(lastMeasure - firstMeasure).rounded(toPlaces: 1))"
            } else {
                cell.measureDifferenceLabel.text = "---"
            }
        }
        
        return cell
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
            let measureType = measureData["type"] as? MeasureType else { return }
        
        if measureType == .Sync {
            
            guard let measuresDataSyncArray = measureData["measures"] as? Array<Dictionary<String, Any>> else { return }
            
            for measureDataSync in measuresDataSyncArray {
                
                guard let weight = measureDataSync["weight"] as? Float,
                    let date = measureDataSync["date"] as? Date else { continue }
                
                let newMeasure = Measure(value: String(describing: weight),
                                         unit: "Kg",
                                         date: date)
                
                MeasureBO.saveMeasure(newMeasure)
            }
        } else if measureType == .Scale {
            
            if let measureDataScaleArray = measureData["measure"] as? Dictionary<String, Any> {
                
                if let stable = measureDataScaleArray["stable"] as? Bool,
                    let weight = measureDataScaleArray["weight"] as? Float {
                    
                    if stable {
                        self.measure = Measure(value: String(describing: weight), unit: "Kg", date: Date())
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
