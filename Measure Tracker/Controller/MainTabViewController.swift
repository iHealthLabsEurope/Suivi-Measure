//
//  MainTabViewController.swift
//  Measure Tracker
//
//  Created by Gustavo Serra on 16/11/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let barItems = self.tabBar.items?.enumerated() else { return }

        for item in barItems {
            
            item.element.setTitleTextAttributes([NSForegroundColorAttributeName: Colors.secondaryColor.color], for:.selected)
            
            switch item.offset {
            case 0:
                item.element.title = "principalTitleButton".localized
            case 1:
                item.element.title = "measuresTitleButton".localized
            case 2:
                item.element.title = "profileTitleButton".localized
            default:
                break
            }
        }
    }
}
