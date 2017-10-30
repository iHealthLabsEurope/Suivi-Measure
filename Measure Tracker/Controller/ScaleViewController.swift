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
    
    @IBOutlet weak var dayWeightStackView: UIStackView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    
    @IBOutlet weak var weightGraphView: UIView!
    var weightGraph: ScrollableGraphView?

    @IBOutlet weak var addWeightButton: UIButton!
    
    var isMenuActive: Bool = false
    
    var bluetoothManager: CBCentralManager?
    
    var user: User?
    
    var measures: [Measure] = []
    var measure: Measure?
    
    private func setupView() {
        
        self.measuresButtonLabel.text = "measuresTitleButton".localized
        self.measuresButtonLabel.textColor = Colors.secondaryColor.color
        self.profileButtonLabel.text = "profileTitleButton".localized
        self.profileButtonLabel.textColor = Colors.secondaryColor.color
    }
    
    private func addGraph() {
        
        self.weightGraph = ScrollableGraphView(frame: self.weightGraphView.bounds, dataSource: self)

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
        self.weightGraph?.backgroundFillColor = UIColor.clear
        self.weightGraph?.showsHorizontalScrollIndicator = false
        self.weightGraph?.shouldAnimateOnAdapt = false
        self.weightGraph?.direction = .leftToRight
        
        guard let firstMeasure = self.measures.first,
                let firstWeight = Double(firstMeasure.value) else { return }
        
        self.weightGraph?.rangeMax = firstWeight + 10
        
        while true {

            if let _ = self.measures.first(where: {
                
                if let measure = Double($0.value),
                    let rangeMaxCurrent = self.weightGraph?.rangeMax {
                    return measure > rangeMaxCurrent
                }
                
                return false
            })
            {
                self.weightGraph?.rangeMax += 5
            } else {
                break
            }
        }

        self.weightGraph?.rangeMin = firstWeight - 3

        // Add everything to the graph.
        self.weightGraph?.addReferenceLines(referenceLines: referenceLines)
        self.weightGraph?.addPlot(plot: linePlot)
        self.weightGraph?.addPlot(plot: dotPlot)
        
        // Add the dataSource
        self.weightGraph?.dataSource = self
        
        // Add graph into subView
        self.weightGraphView.addSubview(self.weightGraph!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = BP5Manager.sharedInstance
        
        self.setupView()
        
        self.bluetoothManager = CBCentralManager(delegate: self,
                                                 queue: nil,
                                                 options: [CBCentralManagerOptionShowPowerAlertKey: false])
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//
//        self.saveMeasure(measure: Measure(value: "63.3", unit: "Kg", date: dateFormatter.date(from: "07/06/2017")!))
//        self.saveMeasure(measure: Measure(value: "63.4", unit: "Kg", date: dateFormatter.date(from: "14/06/2017")!))
//        self.saveMeasure(measure: Measure(value: "63.4", unit: "Kg", date: dateFormatter.date(from: "21/06/2017")!))
//        self.saveMeasure(measure: Measure(value: "63.5", unit: "Kg", date: dateFormatter.date(from: "28/06/2017")!))
//        self.saveMeasure(measure: Measure(value: "63.6", unit: "Kg", date: dateFormatter.date(from: "05/07/2017")!))
//        self.saveMeasure(measure: Measure(value: "63.6", unit: "Kg", date: dateFormatter.date(from: "12/07/2017")!))
//        self.saveMeasure(measure: Measure(value: "63.9", unit: "Kg", date: dateFormatter.date(from: "19/07/2017")!))
//        self.saveMeasure(measure: Measure(value: "64.2", unit: "Kg", date: dateFormatter.date(from: "26/07/2017")!))
//        self.saveMeasure(measure: Measure(value: "64.6", unit: "Kg", date: dateFormatter.date(from: "02/08/2017")!))
//        self.saveMeasure(measure: Measure(value: "65.4", unit: "Kg", date: dateFormatter.date(from: "09/08/2017")!))
//        self.saveMeasure(measure: Measure(value: "66.0", unit: "Kg", date: dateFormatter.date(from: "16/08/2017")!))
//        self.saveMeasure(measure: Measure(value: "66.3", unit: "Kg", date: dateFormatter.date(from: "23/08/2017")!))
//        self.saveMeasure(measure: Measure(value: "66.6", unit: "Kg", date: dateFormatter.date(from: "30/08/2017")!))
//        self.saveMeasure(measure: Measure(value: "67.0", unit: "Kg", date: dateFormatter.date(from: "06/09/2017")!))
//        self.saveMeasure(measure: Measure(value: "68.2", unit: "Kg", date: dateFormatter.date(from: "13/09/2017")!))
//        self.saveMeasure(measure: Measure(value: "68.0", unit: "Kg", date: dateFormatter.date(from: "20/09/2017")!))
//        self.saveMeasure(measure: Measure(value: "68.9", unit: "Kg", date: dateFormatter.date(from: "27/09/2017")!))
//        self.saveMeasure(measure: Measure(value: "69.7", unit: "Kg", date: dateFormatter.date(from: "04/10/2017")!))
//        self.saveMeasure(measure: Measure(value: "69.9", unit: "Kg", date: dateFormatter.date(from: "11/10/2017")!))
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
        
        if let measuresStored = DataManager.sharedInstnce.loadData(forKey: "measures") as? [Measure] {
            
            self.dayWeightStackView.isHidden = false
            self.emptyView.isHidden = true

            self.measures = measuresStored.sorted(by: { $0.0.date < $0.1.date })

            guard let lastMeasure = self.measures.last else { return }
            
            self.weightLabel.text = lastMeasure.value
            self.weightUnitLabel.text = lastMeasure.unit
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            self.dayLabel.text = dateFormatter.string(from: lastMeasure.date)
            
            self.addGraph()
        } else {
 
            self.emptyView.titleLabel.text = "noMeasureDataTitle".localized
            self.emptyView.subTitleLabel.text = "noMeasureDataSubTitle".localized
            self.emptyView.imageView.image = UIImage(named: "no_data_graph")
            self.emptyView.actionButton.isHidden = true
            
            self.dayWeightStackView.isHidden = true
            self.emptyView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        
        self.weightGraph?.dataSource = nil
        self.weightGraph?.removeFromSuperview()
        self.weightGraph = nil
    }
    
    override func viewDidLayoutSubviews() {
        
        self.weightGraph?.frame = self.weightGraphView.bounds
        self.view.layoutSubviews()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        if segue.identifier == "segueToMeasure" {
//
//            let type: MeasureType = sender as! MeasureType
//
//            let measureViewController: MeasureViewController = segue.destination as! MeasureViewController
//            
//            measureViewController.measureType = type
//        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "segueToMeasure" {
            
            guard let _ = sender as? MeasureType else { return false }
        }
        
        return true
    }
 

    @IBAction func measuresButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToMeasures", sender: sender)
    }
    
    @IBAction func profileButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "segueToProfile", sender: sender)
    }
}

extension ScaleViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
}

extension ScaleViewController: ScrollableGraphViewDataSource {
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        guard let measure = Double(self.measures[pointIndex].value) else { return 0.0 }
        
        return measure
    }
    
    func label(atIndex pointIndex: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        return dateFormatter.string(from: self.measures[pointIndex].date)
    }
    
    func numberOfPoints() -> Int {
        return self.measures.count
    }
}

extension ScaleViewController {
    
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
                
                self.view.layoutIfNeeded()
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
