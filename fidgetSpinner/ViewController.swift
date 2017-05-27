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
    var spinCount = 0
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
        setupScene()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }
    
}

private extension ViewController {
    
    func setupScene() {
        scene = SKScene(size: spinnerView.frame.size)
        scene.backgroundColor = UIColor.clear
        scene.scaleMode = .aspectFill
        
        spinnerView.layer.borderColor = nil
        spinnerView.presentScene(scene)
        
        spinnerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: spinnerView.frame.width/1.2, height: spinnerView.frame.height/1.2))
        spinnerNode.physicsBody = SKPhysicsBody(rectangleOf: spinnerNode.size)
        spinnerNode.physicsBody?.affectedByGravity = false
        spinnerNode.physicsBody?.angularDamping = 0.85
        spinnerNode.physicsBody?.mass = 10
        spinnerNode.anchorPoint = CGPoint(x: 0.5, y: 0.42)
        let texture = SKTexture(image: #imageLiteral(resourceName: "fidget"))
        spinnerNode.texture = texture
        spinnerNode.position = CGPoint(x: scene.frame.width/2, y: scene.frame.height/2)
        
        let circleNode = SKShapeNode(circleOfRadius: spinnerView.frame.width/10)
        circleNode.fillColor = UIColor.red
        circleNode.position = CGPoint(x: scene.frame.width/2, y: scene.frame.height/2)
        
        spinnerView.scene?.addChild(spinnerNode)
        spinnerView.scene?.addChild(circleNode)
    }
    
    func configureMotionManager() {
        motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { data, error in
                guard let data = data else { return }
                
                OperationQueue.main.addOperation {
                    
                    if data.userAcceleration.x < -0.2 {
                        self.spinnerNode.physicsBody?.applyAngularImpulse(CGFloat(data.userAcceleration.x) * 50)
                    }
                    if let physicsBody = self.spinnerNode.physicsBody {
                        let mph = abs(Int(physicsBody.angularVelocity * 2.24))
                        self.yLabel.text = "\(mph) MPH"
                    }
                    
                    self.xLabel.text = "\(self.spinnerNode.zRotation)"
                    self.zLabel.text = ""
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



