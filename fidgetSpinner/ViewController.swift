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
import Social
import GameKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var motionManager = CMMotionManager()
    var spinCount = 0 {
        didSet {
            UserDefaults.standard.set(spinCount, forKey: Keys.spins)
        }
    }
    var oldSpins = UserDefaults.standard.integer(forKey: Keys.spins)
    var scene = SKScene()
    var spinnerNode = SKSpriteNode()
    var circleNode = SKShapeNode()
    var totalDegrees: Double = 0
    var previousDegrees: Double = 0
    var isTouchingCircle = false
    var touchRecognizer = UITapGestureRecognizer()
    var currentSpinner: Spinner {
        if let key = UserDefaults.standard.value(forKey: Keys.spinner) as? String {
            return spinners[key] ?? Spinner()
        } else {
            return Spinner()
        }
    }
    var gcEnabled = false
    var gcDefaultLeaderBoard = ""

    
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
    @IBOutlet weak var leaderboardButton: UIButton!
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        configureMotionManager()
        spinnerView.layer.cornerRadius = 5
        spinnerView.clipsToBounds = true
        spinCount = UserDefaults.standard.integer(forKey: Keys.spins)
        self.xLabel.text = "\(0) spins/min"
        self.yLabel.text = String(format: "%.0f spins" , arguments: [0])
        circleView.layer.borderWidth = 1.0
        circleView.layer.borderColor = UIColor.darkGray.cgColor
        topView.alpha = 0
        spinnerView.alpha = 0
        restartButton.alpha = 0
        stopButton.alpha = 0
        spinnersButton.alpha = 0
        leaderboardButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene(with: currentSpinner)
        circleView.layer.cornerRadius = circleView.frame.width/2
        circleView.backgroundColor = currentSpinner.color
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
                self.leaderboardButton.alpha = 1.0
            }, completion: { done in
                let tutorialShown = UserDefaults.standard.bool(forKey: Keys.tutorialShown)
                if !tutorialShown {
                    self.performSegue(withIdentifier: "presentOnboarding", sender: self)
                }
            })
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func stopButtonTapped() {
        spinnerNode.physicsBody?.angularVelocity = 0
        motionManager.stopDeviceMotionUpdates()
        configureMotionManager()
    }
    
    
    @IBAction func circlePressed(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            isTouchingCircle = true
            circleView.alpha = 1.0
            circleView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
            circleView.layer.borderWidth = 1.5
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .ended:
            isTouchingCircle = false
            circleView.alpha = 1.0
            circleView.layer.borderWidth = 1.0
            circleView.layer.borderColor = UIColor.darkGray.cgColor
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            reportScore(shouldShowLeaderboard: false)
        default:
            break
        }
    }
    
    @IBAction func leaderboardButtonTapped() {
        reportScore(shouldShowLeaderboard: true)
    }
    
    @IBAction func spinnersButtonTapped() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    @IBAction func restartButtonTapped() {
        guard SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) else { return }
        guard let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else { return }
        
        UIGraphicsBeginImageContext(view.frame.size)
        self.view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        socialController.add(image)
        socialController.setInitialText("I've spun my fidget phone \(spinCount) times already.")
        socialController.completionHandler = {
            (result: SLComposeViewControllerResult) in
            switch result {
            case .cancelled:
                print("cancelled")
            case .done:
                print("success")
            }
        }
        self.present(socialController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        configureMotionManager()
    }
    
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
        spinnerNode.physicsBody?.angularDamping = 0.1
        spinnerNode.physicsBody?.mass = spinner.mass
        spinnerNode.anchorPoint = CGPoint(x: 0.5, y: 0.445)
        let texture = SKTexture(image: spinner.image)
        spinnerNode.texture = texture
        spinnerNode.position = CGPoint(x: scene.frame.width/2, y: scene.frame.height/2)

        spinnerView.scene?.addChild(spinnerNode)
        spinnerView.scene?.addChild(circleNode)
    }
    
    
    // MARK: - Motion manager
    
    func configureMotionManager() {
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
                        var x = CGFloat(data.userAcceleration.x * -1)
                        if x > 1 {
                            x = 1
                        }
                        self.spinnerNode.physicsBody?.applyAngularImpulse(x)
                    }
                    
                    // Calculate rpm
                    if let physicsBody = self.spinnerNode.physicsBody {
                        let rpm = abs(Int(physicsBody.angularVelocity * 30/CGFloat.pi))
                        let diff: CGFloat = (CGFloat(rpm) * 0.001)
                        self.circleView.backgroundColor = UIColor(red: self.currentSpinner.red + diff, green: self.currentSpinner.green + diff, blue: self.currentSpinner.blue + diff, alpha: 1.0)
                        self.xLabel.text = "\(rpm) spins/min"
                    }
                    
                    // Calculate spins
                    let spins = (self.totalDegrees / 360) + Double(self.oldSpins)
                    self.spinCount = Int(spins)
                    self.yLabel.text = String(format: "%.0f spins" , arguments: [spins])
                }
                self.previousDegrees = degrees
            })
        } else {
            print("no motion")
        }
    }

    
    // MARK: - Game center
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            guard let viewController = viewController else { return }
            self.present(viewController, animated: true, completion: nil)
            self.motionManager.stopDeviceMotionUpdates()
            if localPlayer.isAuthenticated {
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { leaderboardIdentifer, error in
                    if error != nil {
                        print(error as Any)
                    } else if let leaderboardId = leaderboardIdentifer {
                        self.gcDefaultLeaderBoard = leaderboardId
                    }
                })
                
            } else {
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
            }
        }
    }
    
    // MARK: - Score reporting
    
    func reportScore(shouldShowLeaderboard: Bool) {
        let score = GKScore(leaderboardIdentifier: Keys.leaderBoardID)
        score.value = Int64(spinCount)
        GKScore.report([score]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Score submitted to your Leaderboard!")
                OperationQueue.main.addOperation {
                    if shouldShowLeaderboard {
                        self.showLeaderboard()
                    }
                }
            }
        }
    }
    
    func showLeaderboard() {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = Keys.leaderBoardID
        self.motionManager.stopDeviceMotionUpdates()
        self.present(gcVC, animated: true, completion: nil)
    }
    
}



// MARK: - Game center controller delegate

extension ViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        configureMotionManager()
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



