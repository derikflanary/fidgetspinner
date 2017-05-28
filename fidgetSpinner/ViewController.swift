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
    
    // MARK: - Properties
    
    var motionManager = CMMotionManager()
    var spinCount = 0
    var scene = SKScene()
    var spinnerNode = SKSpriteNode()
    var circleNode = SKShapeNode()
    var totalDegrees: Double = 0
    var previousDegrees: Double = 0
    var isTouchingCircle = false
    var touchRecognizer = UITapGestureRecognizer()
    var currentSpinner = Spinner()

    
    // MARK: - Interface properties
    
    @IBOutlet weak var spinnerView: SKView!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var spinnersButton: UIButton!
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMotionManager(with: currentSpinner)
        spinnerView.layer.cornerRadius = 5
        spinnerView.clipsToBounds = true
        self.xLabel.text = "\(0) spins/min"
        self.yLabel.text = String(format: "%.0f spins" , arguments: [0])
        circleView.backgroundColor = UIColor(red: 0.5, green: 0.69, blue: 0.86, alpha: 1.0)
        topView.alpha = 0
        spinnerView.alpha = 0
        restartButton.alpha = 0
        stopButton.alpha = 0
        spinnersButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene(with: currentSpinner)
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.clipsToBounds = true
        topView.layer.cornerRadius = 10
        topView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.backgroundColor = UIColor.white
        }) { done in
            UIView.animate(withDuration: 0.5, animations: { 
                self.topView.alpha = 1.0
                self.spinnerView.alpha = 1.0
                self.stopButton.alpha = 1.0
                self.restartButton.alpha = 1.0
                self.spinnersButton.alpha = 1.0
            }, completion: { done in
                let tutorialShown = UserDefaults.standard.bool(forKey: "tutorialShown")
                if !tutorialShown {
                    self.performSegue(withIdentifier: "presentOnboarding", sender: self)
                }
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        motionManager.stopDeviceMotionUpdates()
    }
    
    
    // MARK: - Actions
    
    @IBAction func stopButtonTapped() {
        spinnerNode.physicsBody?.angularVelocity = 0
        motionManager.stopDeviceMotionUpdates()
        configureMotionManager(with: currentSpinner)
    }
    
    
    @IBAction func circlePressed(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isTouchingCircle = true
            circleView.alpha = 0.8
        case .ended:
            isTouchingCircle = false
            circleView.alpha = 1.0
        default:
            break
        }
    }
    
    @IBAction func restartButtonTapped() {
        let alert = UIAlertController(title: "Reset?", message: "Are you sure you want to reset your spins?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .destructive) { action in
            self.spinnerNode.physicsBody?.angularVelocity = 0
            self.motionManager.stopDeviceMotionUpdates()
            self.spinCount = 0
            self.totalDegrees = 0
            self.previousDegrees = 0
            self.configureMotionManager(with: self.currentSpinner)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) { }
    
}


// MARK: - Private functions

private extension ViewController {
    
    func setupScene(with spinner: Spinner) {
        scene = SKScene(size: spinnerView.frame.size)
        scene.backgroundColor = UIColor.clear
        scene.scaleMode = .aspectFill
        
        spinnerView.layer.borderColor = nil
        spinnerView.presentScene(scene)
        
        spinnerNode = SKSpriteNode(color: UIColor.gray, size: CGSize(width: spinnerView.frame.width/1.2, height: spinnerView.frame.height/1.2))
        spinnerNode.physicsBody = SKPhysicsBody(rectangleOf: spinnerNode.size)
        spinnerNode.physicsBody?.affectedByGravity = false
        spinnerNode.physicsBody?.angularDamping = 0.2
        spinnerNode.physicsBody?.mass = spinner.mass
        spinnerNode.anchorPoint = CGPoint(x: 0.5, y: 0.445)
        let texture = SKTexture(image: spinner.image)
        spinnerNode.texture = texture
        spinnerNode.position = CGPoint(x: scene.frame.width/2, y: scene.frame.height/2)

        spinnerView.scene?.addChild(spinnerNode)
        spinnerView.scene?.addChild(circleNode)
    }
    
    func configureMotionManager(with spinner: Spinner) {
        motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { data, error in
                guard let data = data else { return }
                let zRotation = Double(self.spinnerNode.zRotation)
                let degrees = zRotation.degrees()
                if degrees - self.previousDegrees > 0 {
                    self.totalDegrees += (degrees - self.previousDegrees)
                }

                OperationQueue.main.addOperation {
                    // Add impulse to spin
                    if data.userAcceleration.x < -0.2 && self.isTouchingCircle {
                        if let physicsBody = self.spinnerNode.physicsBody, physicsBody.angularVelocity < 60 {
                            self.spinnerNode.physicsBody?.applyAngularImpulse(CGFloat(data.userAcceleration.x) * -1)
                        }
                    }
                    
                    // Calculate rpm
                    if let physicsBody = self.spinnerNode.physicsBody {
                        let rpm = abs(Int(physicsBody.angularVelocity * 30/CGFloat.pi))
                        let diff: CGFloat = (CGFloat(rpm) * 0.001)
                        self.circleView.backgroundColor = UIColor(red: spinner.red + diff, green: spinner.green + diff, blue: spinner.blue, alpha: 1.0)
                        self.xLabel.text = "\(rpm) spins/min"
                    }
                    
                    // Calculate spins
                    let spins = self.totalDegrees / 360
                    self.yLabel.text = String(format: "%.0f spins" , arguments: [spins])
                }
                self.previousDegrees = degrees
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




