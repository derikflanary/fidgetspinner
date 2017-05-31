//
//  UIViewController+Extensions.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/31/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showOkAlert(with title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
