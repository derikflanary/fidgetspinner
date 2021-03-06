//
//  OnboardingViewController.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/27/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    // MARK: - Properties
    
    var tapGestureRecognizer = UITapGestureRecognizer()
    var upSwipeRecognizer = UISwipeGestureRecognizer()
    var downSwipeRecognizer = UISwipeGestureRecognizer()
    
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    // MARK: - View life cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tapGestureRecognizer.addTarget(self, action: #selector(viewTapped))
        transparentView.addGestureRecognizer(tapGestureRecognizer)
        upSwipeRecognizer.addTarget(self, action: #selector(viewSwiped))
        upSwipeRecognizer.direction = .up
        downSwipeRecognizer.addTarget(self, action: #selector(viewSwiped))
        downSwipeRecognizer.direction = .down
        view.addGestureRecognizer(upSwipeRecognizer)
        view.addGestureRecognizer(downSwipeRecognizer)
        popView.layer.cornerRadius = 10
        popView.clipsToBounds = true
        pageControl.updateCurrentPageDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.75, animations: {
            self.transparentView.alpha = 0.6
        })
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TutorialPageViewController {
            vc.pageDelegate = self
        }
    }

    
    // MARK: - Actions
    
    @IBAction func exitButtonTapped() {
        dismiss()
    }
    
    func viewTapped() {
        dismiss()
    }
    
    func viewSwiped() {
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.transparentView.alpha = 0
        }, completion: { (done) in
            UserDefaults.standard.set(true, forKey: Keys.tutorialShown)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
}


// MARK: - Page delegate

extension OnboardingViewController: PageDelegate {
    
    func paged(page: Int) {
        pageControl.currentPage = page
        pageControl.updateCurrentPageDisplay()
    }
    
}
           
