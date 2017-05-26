//
//  ViewController.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/26/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var motionManager = CMMotionManager()
    var initialAttitude: CMAttitude?
    var isSpinningClockwise = true
    var spinningStarted = false
    var spinCount = 0

    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMotionManager()
        spinnerView.layer.cornerRadius = 5
        spinnerView.clipsToBounds = true
    }
    

    @IBAction func startButtonTapped() {
        initialAttitude = nil
        spinningStarted = true
        configureMotionManager()
    }
}

private extension ViewController {
    
    func configureMotionManager() {
        motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (data, error) in
                guard let data = data else { return }
                
                if let initialAttitude = self.initialAttitude {
                    // translate the attitude
                    data.attitude.multiply(byInverseOf: initialAttitude)
                    
                    self.xLabel.text = "roll: \(data.attitude.roll.degrees())"
                    self.yLabel.text = "yaw: \(data.attitude.yaw.degrees())"
                    
                    
                    let rotation = atan2(data.gravity.x, data.gravity.y) - Double.pi
                    self.zLabel.text = "\(rotation)"
                    
//                    self.spinnerView.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
                    self.spinnerView.transform = CGAffineTransform(rotationAngle: CGFloat(data.attitude.yaw))
                    
                    
                } else {
                    self.initialAttitude = self.motionManager.deviceMotion?.attitude
                }
                
            })
        } else {
            print("no motion")
        }

    }


}

extension Double {
    
    func degrees() -> Double {
        if self < 0 {
            let degrees = 180 / Double.pi * self
            return degrees + 360
        } else {
            return 180 / Double.pi * self
        }
    }

}

extension CMAttitude {
    
    func magnitude() -> Double {
        return sqrt(pow(self.roll, 2) + pow(self.yaw, 2) + pow(self.pitch, 2))
    }
    
}



