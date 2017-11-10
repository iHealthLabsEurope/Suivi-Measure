//
//  LoadingAppViewController.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 25/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class LoadingAppViewController: UIViewController {

    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: Empty!
    
    private func setupView() {
        
        self.emptyView.isHidden = true
        
        self.loadingActivityIndicatorView.color = Colors.secondaryColor.color
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()

        let healthUser = HealthUser()
        healthUser.clientID = "5996a7355be34b54917fbeba737eb1f9"
        healthUser.clientSecret = "3da6b0da36e14fa6a5d69e8e9031418e"
        healthUser.userAccount = "g.serra@ihealthlabs.com"
        
        IHSDKCloudUser.commandGetSDKUserInstance().commandSDKUserValidation(healthUser, userDeviceAccess: { (devicesAccess) in
            print("Devices Access: \(devicesAccess)")
        }, userValidationSuccess: { (authResult) in
            print("Auth Result: \(authResult)")
            
            self.loadingActivityIndicatorView.stopAnimating()
            
            if authResult == UserAuthen_LoginSuccess ||
                authResult == UserAuthen_TrySuccess {
                
                HS4Manager.sharedInstance.discoveryInBackground()
                BP5Manager.sharedInstance
                
                self.performSegue(withIdentifier: "segueToScale", sender: nil)
            } else {

                self.emptyView.titleLabel.text = "loginSDKFailTitle".localized
                self.emptyView.subTitleLabel.text = "loginSDKFailMessage".localized
                self.emptyView.imageView.image = UIImage(named: "logo_partner")
                self.emptyView.actionButton.isHidden = true
                
                self.emptyView.isHidden = false
            }
            
        }, userValidationReturn: { (user) in
            print("Auth User: \(user)")
        }) { (error) in
            print("Auth Error: \(error)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
