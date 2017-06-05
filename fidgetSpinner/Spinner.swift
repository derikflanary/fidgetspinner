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
    
    enum UnlockType {
        case spin
        case review
        case share
    }
    
    var mass: CGFloat
    var title: String
    var image: UIImage
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var cost: Int
    var color: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    var unlockType: UnlockType
    
    init() {
        title = "Default"
        mass = 1.5
        image = #imageLiteral(resourceName: "fidget2")
        red = 0.5
        green = 0.69
        blue = 0.86
        cost = 0
        unlockType = .spin
    }
    
    init(title: String, mass: CGFloat, image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, cost: Int, unlockType: UnlockType = .spin) {
        self.title = title
        self.mass = mass
        self.image = image
        self.red = red
        self.green = green
        self.blue = blue
        self.cost = cost
        self.unlockType = unlockType
    }
}

let spinnerKeys = ["default",
                   "delic",
                   "army",
                   "tribal",
                   "prez",
                   "usa",
                   "hotdog",
                   "cat",
                   "mindtrip"]

let spinners: [String: Spinner] = [ "default": Spinner(),
                                    "army": Spinner(title: "Sergeant", mass: 2.0, image: #imageLiteral(resourceName: "army"), red: 0.05, green: 0.05, blue: 0.05, cost: 10000),
                                    "delic": Spinner(title: "Wild Thing", mass: 1.0, image: #imageLiteral(resourceName: "delic"), red: 0.43, green: 0.96, blue: 0.19, cost: 5000),
                                    "prez": Spinner(title: "Prez", mass: 4.0, image: #imageLiteral(resourceName: "trump"), red: 0.93, green: 0.82, blue: 0.45, cost: 50000),
                                    "tribal": Spinner(title: "Tribal", mass: 0.75, image: #imageLiteral(resourceName: "tribal"), red: 0.36, green: 0.01, blue: 0.02, cost: 20000),
                                    "usa": Spinner(title: "USA", mass: 1.5, image: #imageLiteral(resourceName: "usa"), red: 0.69, green: 0.13, blue: 0.20, cost: 100000),
                                    "hotdog": Spinner(title: "Hotdogs", mass: 0.9, image: #imageLiteral(resourceName: "hotdog"), red: 0.9, green: 0.27, blue: 0.17, cost: 150000),
                                    "cat": Spinner(title: "Can Haz Catz", mass: 1.25, image: #imageLiteral(resourceName: "cat"), red: 0.99, green: 0.64, blue: 0.65, cost: 250000, unlockType: .share),
                                    "mindtrip": Spinner(title: "Mind Trip", mass: 0.5, image: #imageLiteral(resourceName: "mindtrip"), red: 0.26, green: 0.43, blue: 0.78, cost: 500000)
]


