//
//  BloodPressureMeasureTableViewCell.swift
//  Measure Tracker
//
//  Created by Gustavo Serra on 07/11/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class BloodPressureMeasureTableViewCell: UITableViewCell {

    @IBOutlet weak var pointImageView: UIImageView!
    @IBOutlet weak var measureDateLabel: UILabel!
    @IBOutlet weak var bloodPressureMeasureLabel: UILabel!
    @IBOutlet weak var bloodPressureMeasureUnitLabel: UILabel!
    @IBOutlet weak var heartMeasureLabel: UILabel!
    @IBOutlet weak var heartMeasureUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
