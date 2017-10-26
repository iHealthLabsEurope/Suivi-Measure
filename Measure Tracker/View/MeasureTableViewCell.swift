//
//  MeasureTableViewCell.swift
//  Suivi de Poids
//
//  Created by Gustavo Serra on 26/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

class MeasureTableViewCell: UITableViewCell {

    @IBOutlet weak var pointImageView: UIImageView!
    @IBOutlet weak var measureLabel: UILabel!
    @IBOutlet weak var measureUnitLabel: UILabel!
    @IBOutlet weak var measureDateLabel: UILabel!
    @IBOutlet weak var measureDifferenceLabel: UILabel!
    @IBOutlet weak var measureDifferenceUnitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
