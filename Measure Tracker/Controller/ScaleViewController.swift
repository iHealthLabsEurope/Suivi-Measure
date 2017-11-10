//
//  ScaleViewController.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 19/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit
import CoreBluetooth
import ScrollableGraphView

class ScaleViewController: UIViewController {
    
    @IBOutlet weak var measuresButton: UIButton!
    @IBOutlet weak var measuresButtonLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var profileButtonLabel: UILabel!
    
    @IBOutlet weak var emptyView: Empty!
  
    @IBOutlet weak var dayMeasuresStackView: UIStackView!
    
    @IBOutlet weak var dayWeightStackView: UIStackView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weightStackView: UIStackView!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var weightHelpButton: UIButton!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var dayBloodPressionStackView: UIStackView!
    @IBOutlet weak var bloodPressureDayLabel: UILabel!
    @IBOutlet weak var bloodPressureStackView: UIStackView!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var bloodPressureUnitLabel: UILabel!
    @IBOutlet weak var heartPulseLabel: UILabel!
    @IBOutlet weak var heartPulseUnitLabel: UILabel!
    @IBOutlet weak var bloodPressureAddButton: UIButton!
    
    @IBOutlet weak var measuresSegmentedControl: UISegmentedControl!
    @IBOutlet weak var weightGraphView: UIView!
    var measureGraph: ScrollableGraphView?
    
    var isMenuActive: Bool = false
    
    var bluetoothManager: CBCentralManager?
    
    var user: User?
    
    var weightMeasures: [Weight] = []
    var weightMeasure: Weight?
    
    var bloodPressureMeasures: [BloodPressure] = []
    var bloodPressureMeasure: BloodPressure?
    
    private func setupView() {
        
        self.measuresButtonLabel.text = "measuresTitleButton".localized
        self.measuresButtonLabel.textColor = Colors.secondaryColor.color
        self.profileButtonLabel.text = "profileTitleButton".localized
        self.profileButtonLabel.textColor = Colors.secondaryColor.color
        
        self.dayLabel.textColor = Colors.textColor.color
        self.weightLabel.textColor = Colors.primaryColor.color
        self.weightUnitLabel.textColor = Colors.textColor.color
        self.weightHelpButton.setImage(UIImage(named: "help_scale"), for: .normal)
        self.weightHelpButton.imageView?.layer.masksToBounds = false
        self.weightHelpButton.imageView?.layer.shadowColor = Colors.textColor.color.cgColor
        self.weightHelpButton.imageView?.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.weightHelpButton.imageView?.layer.shadowOpacity = 1
        self.weightHelpButton.imageView?.layer.shadowRadius = 3
        self.weightHelpButton.imageView?.layer.shadowPath = UIBezierPath(roundedRect: (self.weightHelpButton.imageView?.bounds)!, cornerRadius: (self.weightHelpButton.imageView?.frame)!.height).cgPath
        self.weightHelpButton.setTitle("scaleHelpTitleButton".localized, for: .normal)
        self.weightHelpButton.setTitleColor(Colors.secondaryColor.color, for: .normal)
        
        self.bloodPressureDayLabel.textColor = Colors.textColor.color
        self.bloodPressureLabel.textColor = Colors.tertiaryColor.color
        self.bloodPressureUnitLabel.textColor = Colors.textColor.color
        self.heartPulseLabel.textColor = Colors.tertiaryColor.color
        self.heartPulseUnitLabel.textColor = Colors.textColor.color
        self.bloodPressureAddButton.setImage(UIImage(named: "add_pressure"), for: .normal)
        self.bloodPressureAddButton.imageView?.layer.masksToBounds = false
        self.bloodPressureAddButton.imageView?.layer.shadowColor = Colors.textColor.color.cgColor
        self.bloodPressureAddButton.imageView?.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.bloodPressureAddButton.imageView?.layer.shadowOpacity = 1
        self.bloodPressureAddButton.imageView?.layer.shadowRadius = 3
        self.bloodPressureAddButton.imageView?.layer.shadowPath = UIBezierPath(roundedRect: (self.bloodPressureAddButton.imageView?.bounds)!, cornerRadius: (self.bloodPressureAddButton.imageView?.frame)!.height).cgPath
        self.bloodPressureAddButton.setTitle("bloodPressureStartTitleButton".localized, for: .normal)
        self.bloodPressureAddButton.setTitleColor(Colors.secondaryColor.color, for: .normal)
    }
    
    private func addWeightGraph() {
        
        self.measureGraph = ScrollableGraphView(frame: self.weightGraphView.bounds, dataSource: self)

        // Setup the line plot.
        let linePlot = LinePlot(identifier: "poidsLine")
        
        linePlot.lineCap = kCALineCapButt
        linePlot.lineWidth = 0
        linePlot.lineColor = Colors.primaryColor.color
        linePlot.lineStyle = .smooth
        
        linePlot.shouldFill = true
        linePlot.fillType = .gradient
        linePlot.fillGradientType = .linear
        linePlot.fillGradientStartColor = Colors.primaryColor.color
        linePlot.fillGradientEndColor = Colors.primaryColorLowContrast.color
        
        linePlot.adaptAnimationType = .easeOut
        linePlot.animationDuration = 1.0
        
        // Setup the dot plot.
        let dotPlot = DotPlot(identifier: "poidsDots")
        
        dotPlot.dataPointType = .circle
        dotPlot.dataPointSize = 2
        dotPlot.dataPointFillColor = Colors.secondaryColor.color
        
        dotPlot.adaptAnimationType = .easeOut
        
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.shouldShowReferenceLines = true
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = Colors.secondaryColor.color.withAlphaComponent(0.8)
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        //referenceLines.relativePositions = [0.25, 0.4, 0.5, 0.6, 0.75]
        
        // Setup the graph
        self.measureGraph?.backgroundFillColor = UIColor.clear
        self.measureGraph?.showsHorizontalScrollIndicator = false
        self.measureGraph?.shouldAnimateOnAdapt = false
        self.measureGraph?.direction = .rightToLeft
        
        guard let firstMeasure = self.weightMeasures.first,
                let firstWeight = Double(firstMeasure.value) else { return }
        
        self.measureGraph?.rangeMax = firstWeight + 10
        
        while true {

            if let _ = self.weightMeasures.first(where: {
                
                if let measure = Double($0.value),
                    let rangeMaxCurrent = self.measureGraph?.rangeMax {
                    return measure > rangeMaxCurrent
                }
                
                return false
            })
            {
                self.measureGraph?.rangeMax += 5
            } else {
                break
            }
        }

        self.measureGraph?.rangeMin = firstWeight - 3

        // Add everything to the graph.
        self.measureGraph?.addReferenceLines(referenceLines: referenceLines)
        self.measureGraph?.addPlot(plot: linePlot)
        self.measureGraph?.addPlot(plot: dotPlot)
        
        // Add the dataSource
        self.measureGraph?.dataSource = self
        
        // Add graph into subView
        self.weightGraphView.addSubview(self.measureGraph!)
    }
    
    private func addBloodPressureGraph() {
        
        self.measureGraph = ScrollableGraphView(frame: self.weightGraphView.bounds, dataSource: self)
        
        // Setup the line plot.
        let diaLinePlot = LinePlot(identifier: "tensionDiaLine")
        
        diaLinePlot.lineCap = kCALineCapButt
        diaLinePlot.lineWidth = 0
        diaLinePlot.lineColor = Colors.primaryColor.color
        diaLinePlot.lineStyle = .smooth
        
        diaLinePlot.shouldFill = true
        diaLinePlot.fillType = .gradient
        diaLinePlot.fillGradientType = .linear
        diaLinePlot.fillGradientStartColor = Colors.tertiaryColor.color
        diaLinePlot.fillGradientEndColor = Colors.tertiaryColorLowContrast.color
        
        diaLinePlot.adaptAnimationType = .easeOut
        diaLinePlot.animationDuration = 0.2
        
        // Setup the dot plot.
        let diaDotPlot = DotPlot(identifier: "tensionDiaDots")
        
        diaDotPlot.dataPointType = .circle
        diaDotPlot.dataPointSize = 2
        diaDotPlot.dataPointFillColor = Colors.secondaryColor.color
        
        diaDotPlot.adaptAnimationType = .easeOut
        
        // Setup the line plot.
        let sysLinePlot = LinePlot(identifier: "tensionSysLine")
        
        sysLinePlot.lineCap = kCALineCapButt
        sysLinePlot.lineWidth = 1
        sysLinePlot.lineColor = Colors.tertiaryColor.color
        sysLinePlot.lineStyle = .smooth
        
        sysLinePlot.shouldFill = false
        
        sysLinePlot.adaptAnimationType = .easeOut
        sysLinePlot.animationDuration = 0.2
        
        // Setup the dot plot.
        let sysDotPlot = DotPlot(identifier: "tensionSysDots")
        
        sysDotPlot.dataPointType = .circle
        sysDotPlot.dataPointSize = 2
        sysDotPlot.dataPointFillColor = Colors.secondaryColor.color
        
        sysDotPlot.adaptAnimationType = .easeOut
        
        // Setup the reference lines.
        let referenceLines = ReferenceLines()
        
        referenceLines.shouldShowReferenceLines = true
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = Colors.secondaryColor.color.withAlphaComponent(0.8)
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(1)
        
        // Setup the graph
        self.measureGraph?.backgroundFillColor = UIColor.clear
        self.measureGraph?.showsHorizontalScrollIndicator = false
        self.measureGraph?.shouldAnimateOnAdapt = false
        self.measureGraph?.direction = .rightToLeft
        self.measureGraph?.rangeMax = 180
        self.measureGraph?.rangeMin = 50
        
        // Add everything to the graph.
        self.measureGraph?.addReferenceLines(referenceLines: referenceLines)
        self.measureGraph?.addPlot(plot: diaLinePlot)
        self.measureGraph?.addPlot(plot: diaDotPlot)
        self.measureGraph?.addPlot(plot: sysLinePlot)
        self.measureGraph?.addPlot(plot: sysDotPlot)
        
        // Add the dataSource
        self.measureGraph?.dataSource = self
        
        // Add graph into subView
        self.weightGraphView.addSubview(self.measureGraph!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        self.bluetoothManager = CBCentralManager(delegate: self,
                                                 queue: nil,
                                                 options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var isBluetoothPoweredOn: Bool?
        
        if #available(iOS 10.0, *) {
            isBluetoothPoweredOn = self.bluetoothManager?.state == CBManagerState.poweredOn
        } else {
            isBluetoothPoweredOn = self.bluetoothManager?.state.rawValue == CBCentralManagerState.poweredOn.rawValue
        }
        
        if !isBluetoothPoweredOn! {
            
            let alert = UIAlertController(title: "bluetoothTurnOffMessage".localized, message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "bluetoothTurnOffMessageSettingsButton".localized, style: .default, handler: { (action) in
                let url = URL(string: "App-Prefs:root=Bluetooth")
                if let settingsUrl = url {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "bluetoothTurnOffMessageOkButton".localized, style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.manageMeasureData(_:)),
                                               name: NSNotification.Name("MeasureData"),
                                               object: nil)
        
        self.updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        
        self.measureGraph?.dataSource = nil
        self.measureGraph?.removeFromSuperview()
        self.measureGraph = nil
    }
    
    override func viewDidLayoutSubviews() {
        
        self.measureGraph?.frame = self.weightGraphView.bounds
        self.view.layoutSubviews()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "segueToMeasure" {
            
            guard let _ = sender as? WeightMeasureType else { return false }
        }
        
        return true
    }
 
    @IBAction func weightHelpButtonClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: "weightHelpMessage".localized, message: nil, preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "weightHelpMessageOkButton".localized, style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func bloodPressureAddButtonClicked(_ sender: Any) {
        
        let bloodPressureMeasureViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "BloodPressureMeasureViewController") as! BloodPressureMeasureViewController
        
        bloodPressureMeasureViewController.delegate = self
        
        self.present(bloodPressureMeasureViewController, animated: true, completion: nil)
    }
    
    @IBAction func measuresSegmentedControlChanged(_ sender: Any) {
        self.updateGraph()
    }
    
    @IBAction func measuresButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToMeasures", sender: sender)
    }
    
    @IBAction func profileButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToProfile", sender: sender)
    }
    
    private func updateView () {

        self.dayLabel.isHidden = true
        self.weightStackView.isHidden = true
        
        self.bloodPressureDayLabel.isHidden = true
        self.bloodPressureStackView.isHidden = true
        
        let weightMeasuresStored = DataManager.sharedInstnce.loadData(forKey: "measures") as? [Weight]
        let bloodPressureMeasuresStored = DataManager.sharedInstnce.loadData(forKey: "blood_pressure_measures") as? [BloodPressure]
        
        if weightMeasuresStored != nil ||
            bloodPressureMeasuresStored != nil {

            self.emptyView.isHidden = true
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            
            if let _ = weightMeasuresStored {
                
                self.dayLabel.isHidden = false
                self.weightStackView.isHidden = false
                
                self.weightMeasures = weightMeasuresStored!.sorted(by: { $0.0.date < $0.1.date })
                
                guard let lastWeightMeasure = self.weightMeasures.last else { return }
                
                self.weightLabel.text = lastWeightMeasure.value
                self.weightUnitLabel.text = lastWeightMeasure.unit
                
                self.dayLabel.text = dateFormatter.string(from: lastWeightMeasure.date)
            }
            
            if let _ = bloodPressureMeasuresStored {
                
                self.bloodPressureDayLabel.isHidden = false
                self.bloodPressureStackView.isHidden = false
                
                self.bloodPressureMeasures = bloodPressureMeasuresStored!.sorted(by: { $0.0.date < $0.1.date })
                
                guard let lastBloodPressureMeasure = self.bloodPressureMeasures.last else { return }
                
                self.bloodPressureLabel.text = lastBloodPressureMeasure.pressureValue
                self.bloodPressureUnitLabel.text = lastBloodPressureMeasure.pressureUnit
                self.heartPulseLabel.text = lastBloodPressureMeasure.heartValue
                self.heartPulseUnitLabel.text = lastBloodPressureMeasure.heartUnit
                
                self.bloodPressureDayLabel.text = dateFormatter.string(from: lastBloodPressureMeasure.date)
            }
            
            if !self.dayWeightStackView.isHidden && !self.dayBloodPressionStackView.isHidden {
                
                self.separatorView.isHidden = false
            }
            
            self.updateGraph()
        } else {
            
            self.emptyView.titleLabel.text = "noMeasureDataTitle".localized
            self.emptyView.subTitleLabel.text = "noMeasureDataSubTitle".localized
            self.emptyView.imageView.image = UIImage(named: "no_data_graph")
            self.emptyView.actionButton.isHidden = true
            
            self.emptyView.isHidden = false
        }
    }
    
    func updateGraph() {
        
        self.measureGraph?.dataSource = nil
        self.measureGraph?.removeFromSuperview()
        self.measureGraph = nil
        
        if self.measuresSegmentedControl.selectedSegmentIndex == 0 {
            self.addWeightGraph()
        } else {
            self.addBloodPressureGraph()
        }
    }
}

extension ScaleViewController: MeasureDelegate {
    
    func measureFinished(type: MeasureType) {
        
        if type == .Weight {
            
            self.measuresSegmentedControl.selectedSegmentIndex = 0
        } else if type == .BloodPressure {
            
            self.measuresSegmentedControl.selectedSegmentIndex = 1
        }
    }
}

extension ScaleViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}

extension ScaleViewController: ScrollableGraphViewDataSource {
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        if self.measuresSegmentedControl.selectedSegmentIndex == 0 {
            
            guard let measure = Double(self.weightMeasures[pointIndex].value) else { return 0.0 }
            
            return measure
        } else {
            
            let measure = self.bloodPressureMeasures[pointIndex].pressureValue.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: true)
            
            guard let sys = Double(measure[0].lowercased()),
                let dia = Double(measure[1].lowercased()) else { return 0.0 }
            
            if plot.identifier == "tensionDiaLine" ||
                plot.identifier == "tensionDiaDots" {
                return dia
            } else if plot.identifier == "tensionSysLine" ||
                plot.identifier == "tensionSysDots" {
                return sys
            } else {
                return 0.0
            }
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        if self.measuresSegmentedControl.selectedSegmentIndex == 0 {
            return dateFormatter.string(from: self.weightMeasures[pointIndex].date)
        } else {
            return dateFormatter.string(from: self.bloodPressureMeasures[pointIndex].date)
        }
    }
    
    func numberOfPoints() -> Int {
        
        if self.measuresSegmentedControl.selectedSegmentIndex == 0 {
            return self.weightMeasures.count
        } else {
            return self.bloodPressureMeasures.count
        }
    }
}

extension ScaleViewController {
    
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
                
                self.view.layoutIfNeeded()
            }
        } else if measureType == .Scale {
            
            if let measureDataScaleArray = measureData["measure"] as? Dictionary<String, Any> {
                
                if let stable = measureDataScaleArray["stable"] as? Bool,
                    let weight = measureDataScaleArray["weight"] as? Float {
                    
                    if stable {
                        self.weightMeasure = Weight(value: String(describing: weight), unit: "Kg", date: Date())
                    } else {
                        
                        let measureViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MeasureViewController") as! MeasureViewController
                        
                        measureViewController.delegate = self
                        
                        self.present(measureViewController, animated: true, completion: nil)
                    }
                }
            } else if let status = measureData["status"] as? Bool {
                
                if status {
                    HS4Manager.sharedInstance.startMeasureInBackground(HSUnit(rawValue: 1))
                } else {
                    print("Error: \(String(describing: measureData["error"]))")
                }
            }
        }
    }
}
