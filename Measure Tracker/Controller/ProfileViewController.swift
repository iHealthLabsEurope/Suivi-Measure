//
//  ProfileViewController.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 19/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scaleButton: UIButton!
    @IBOutlet weak var scaleButtonLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileHeightLabel: UILabel!
    @IBOutlet weak var profileHeightUnitLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var measure: Weight?
    
    private func setupView() {

        self.scaleButtonLabel.text = "scaleTitleButton".localized
        self.scaleButtonLabel.textColor = Colors.secondaryColor.color
        
        self.profileNameLabel.textColor = Colors.secondaryColor.color
        self.profileHeightLabel.textColor = Colors.textColor.color
        self.profileHeightUnitLabel.textColor = Colors.textColor.color
        
        self.logoutButton.setTitle("logoutTitleButton".localized, for: .normal)
        self.logoutButton.backgroundColor = Colors.backgroundColor.color
        self.logoutButton.setTitleColor(Colors.dangerColor.color, for: .normal)
    }
    
    private func openAppURL(_ scheme: String, completionHandler: @escaping (_ success: Bool) -> ()) {
        
        guard let layeredAppURL = URL(string: scheme)
            else {
                print("BAD Scheme")
                return
        }
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(layeredAppURL, options: [:],
                                      completionHandler: {
                                        (success) in
                                        
                                        completionHandler(success)
            })
        } else {
            
            let success = UIApplication.shared.openURL(layeredAppURL)
            
            completionHandler(success)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        
        if let userStored = DataManager.sharedInstnce.loadData(forKey: "user") as? User {
            
            if userStored.photo != "",
                let userPhotoData = Data(base64Encoded: userStored.photo, options: .ignoreUnknownCharacters) {
                
                self.profileImageView.image = UIImage(data: userPhotoData)
            }
            
            self.profileNameLabel.text = userStored.name
            self.profileHeightLabel.text = userStored.height
        } else {
            
            self.profileNameLabel.text = "--"
            self.profileHeightLabel.text = "-"
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
        self.profileImageView.layer.masksToBounds = true
    }

    @IBAction func scaleButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        
        HS4Manager.sharedInstance.disconnectDevice()
        
        self.openAppURL("ihealth-suivi-partner://") { (result) in
            print("Open: \(result)")
        }
    }
}

extension ProfileViewController {
    
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
                        self.measure = Weight(value: String(describing: weight), unit: "Kg", date: Date())
                    } else {
                        
                        let measureViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "MeasureViewController") as! MeasureViewController
                        self.present(measureViewController, animated: true, completion: nil)
                    }
                }
            } else if let status = measureData["status"] as? Bool {
                
                if status {
                    HS4Manager.sharedInstance.startMeasureInBackground(HSUnit(rawValue: 1))
                } else {
                    print("Error: \(measureData["error"] ?? "unknown")")
                }
            }
        }
    }
}
