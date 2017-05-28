//
//  TutorialPageViewController.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/27/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit

protocol PageDelegate {
    func paged(page: Int)
}

class TutorialPageViewController: UIPageViewController {
    
    // MARK: - Properties
    
    var pageDelegate: PageDelegate?
    var currentPage = 0
    var previousPage = 0

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(number: "1"),
                self.newViewController(number: "2")
        ]
    }()
    
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
}


// MARK: - Private functions

private extension TutorialPageViewController {
    
    func newViewController(number: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page\(number)")
    }
    
}

// MARK: UIPageViewControllerDataSource

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
}


// MARK: - Page delegate

extension TutorialPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pendingViewController = pendingViewControllers.first, let index = orderedViewControllers.index(of: pendingViewController) else { return }
        currentPage = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            previousPage = currentPage
        } else {
            currentPage = previousPage
        }
        pageDelegate?.paged(page: currentPage)
    }
}

