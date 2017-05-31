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

    func configure(with spinner: Spinner?) {
        guard let spinner = spinner else { return }
        
        spinnerImageView.image = spinner.image
        titleLabel.text = spinner.title
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat.pi
            rotateAnimation.duration = CFTimeInterval(HUGE)
            rotateAnimation.delegate = self
            spinnerImageView.layer.add(rotateAnimation, forKey: nil)
        } else {
            spinnerImageView.layer.removeAllAnimations()
        }
    }
    

}

extension SpinnerCell: CAAnimationDelegate {
    
    
    
}
