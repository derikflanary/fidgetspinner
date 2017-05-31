//
//  SpinnerCell.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/30/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit

class SpinnerCell: UITableViewCell, ReusableView {
    
    @IBOutlet weak var spinnerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unlockLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!

    func configure(with spinner: Spinner?, isUnlocked: Bool) {
        guard let spinner = spinner else { return }
        
        spinnerImageView.image = spinner.image
        titleLabel.text = spinner.title
        if isUnlocked {
            contentView.alpha = 1.0
            lockImageView.isHidden = true
            unlockLabel.isHidden = true
        } else {
            contentView.alpha = 0.4
            lockImageView.isHidden = false
            unlockLabel.isHidden = false
            unlockLabel.text = "Unlock at \(spinner.cost) spins"
        }
    }

}
