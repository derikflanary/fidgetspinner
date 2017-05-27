//
//  ViewController.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/26/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit
import CoreMotion
import SpriteKit

class ViewController: UIViewController {
    
    var motionManager = CMMotionManager()
    var initialAttitude: CMAttitude?
    var isSpinningClockwise = true
    var spinningStarted = false
    var spinCount = 0
    var previousDegrees: Double = 0
    var scene = SKScene()
    var spinnerNode = SKSpriteNode()

    @IBOutlet weak var spinnerView: SKView!
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scene = SKScene(size: spinnerView.frame.size)
        scene.backgroundColor = UIColor.white
        spinnerView.presentScene(scene)
        spinnerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: spinnerView.frame.width/3, height: spinnerView.frame.height/3))
        spinnerNode.anchorPoint = CGPoint.zero
        spinnerNode.physicsBody = SKPhysicsBody(rectangleOf: spinnerNode.size)
        spinnerNode.physicsBody?.affectedByGravity = false
        spinnerNode.physicsBody?.angularDamping = 0.75
        spinnerView.scene?.addChild(spinnerNode)
        spinnerNode.position = CGPoint(x: scene.frame.width/2, y: scene.frame.height/2)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
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
            motionManager.deviceMotionUpdateInterval = 0.1
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { (data, error) in
                guard let data = data else { return }
                
                if let initialAttitude = self.initialAttitude {
                    // translate the attitude
                    data.attitude.multiply(byInverseOf: initialAttitude)
                    let yawDegrees = data.attitude.yaw.degrees()
                    let rotation = atan2(data.gravity.x, data.gravity.y) - Double.pi
                    
                    if yawDegrees + self.previousDegrees >= 360 && yawDegrees > self.previousDegrees {
                        self.spinCount += 1
                        self.previousDegrees = 0
                    }
                    
                    OperationQueue.main.addOperation {
//                        self.spinnerView.transform = CGAffineTransform(rotationAngle: CGFloat(data.attitude.yaw))
//                        self.zLabel.text = "spins: \(self.spinCount)"
//                        self.xLabel.text = "previous: \(self.previousDegrees)"
//                        self.yLabel.text = "yaw: \(yawDegrees)"
                        
                        self.xLabel.text = "acceleration: \(data.userAcceleration.x)"
                        if data.userAcceleration.x < -1.5 {
                            self.spinnerNode.physicsBody?.applyAngularImpulse(CGFloat(data.userAcceleration.x))
                        }
                    }

                    if yawDegrees > self.previousDegrees && self.previousDegrees - yawDegrees < 20 {
                        self.previousDegrees = yawDegrees
                    }
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



