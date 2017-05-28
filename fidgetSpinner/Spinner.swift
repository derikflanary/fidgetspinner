//
//  Spinner.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/28/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import Foundation
import UIKit

struct Spinner {
    var mass: CGFloat
    var image: UIImage
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    
    init() {
        mass = 1.5
        image = #imageLiteral(resourceName: "fidget2")
        red = 0.5
        green = 0.69
        blue = 0.86
    }
}
