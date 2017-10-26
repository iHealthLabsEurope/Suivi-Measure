//
//  Empty.swift
//  Nurse
//
//  Created by Gustavo Serra on 05/09/2017.
//  Copyright © 2017 iHealthLabs. All rights reserved.
//

import UIKit

protocol EmptyDelegate: class {
    func actionButtonClicked(_ sender: Any) -> Void
}

class Empty: UIView {

    @IBOutlet var contentView: Empty!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    weak var delegate: EmptyDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("Empty", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.titleLabel.textColor = Colors.textTitleColor.color
        self.subTitleLabel.textColor = Colors.textColor.color
        self.actionButton.setTitleColor(Colors.textWithBackgroudColor.color, for: .normal)
        self.actionButton.backgroundColor = Colors.secondaryColor.color
    }

    @IBAction func actionButtonTapped(_ sender: Any) {
        self.delegate?.actionButtonClicked(sender)
    }
}
