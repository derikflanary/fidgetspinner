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
    var title: String
    var image: UIImage
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    
    init() {
        title = "Default"
        mass = 1.5
        image = #imageLiteral(resourceName: "fidget2")
        red = 0.5
        green = 0.69
        blue = 0.86
    }
    
    init(title: String, mass: CGFloat, image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.title = title
        self.mass = mass
        self.image = image
        self.red = red
        self.green = green
        self.blue = blue
    }
}

let spinnerKeys = ["default", "usa", "army", "cat", "prez", "delic", "tribal", "hotdog", "mindtrip"]

let spinners: [String: Spinner] = [ "default": Spinner(),
                                    "usa": Spinner(title: "USA", mass: 1.5, image: #imageLiteral(resourceName: "usa"), red: 0.5, green: 0.0, blue: 0.0),
                                    "army": Spinner(title: "Sergeant", mass: 2.0, image: #imageLiteral(resourceName: "army"), red: 0.5, green: 0.5, blue: 0.5),
                                    "cat": Spinner(title: "Can Haz Catz", mass: 1.25, image: #imageLiteral(resourceName: "cat"), red: 0.5, green: 0.5, blue: 0.7),
                                    "prez": Spinner(title: "Prez", mass: 4.0, image: #imageLiteral(resourceName: "trump"), red: 0.5, green: 0.5, blue: 0.7),
                                    "delic": Spinner(title: "Wild Thing", mass: 1.0, image: #imageLiteral(resourceName: "delic"), red: 0.5, green: 0.5, blue: 0.7),
                                    "tribal": Spinner(title: "Tribal", mass: 0.75, image: #imageLiteral(resourceName: "tribal"), red: 0.9, green: 0.5, blue: 0.7),
                                    "hotdog": Spinner(title: "Hotdogs", mass: 0.9, image: #imageLiteral(resourceName: "hotdog"), red: 0.9, green: 0.5, blue: 0.9),
                                    "mindtrip": Spinner(title: "Mind Trip", mass: 0.5, image: #imageLiteral(resourceName: "mindtrip"), red: 0.9, green: 0.9, blue: 0.7)
]


