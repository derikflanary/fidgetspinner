//
//  SpinnersViewController.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/30/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit
import StoreKit

class SpinnersViewController: UIViewController {
    
    var spins = UserDefaults.standard.integer(forKey: Keys.spins)
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var allSpinnersPurchased = UserDefaults.standard.bool(forKey: Keys.allSpinnersPurchased)
    
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableViewDataSource: SpinnersDataSource!
    @IBOutlet weak var unlockButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAvailableProducts()
        if allSpinnersPurchased {
            headerView.isHidden = true
            headerView.frame = CGRect.zero
        } else {
            unlockButton.layer.cornerRadius = 20
            unlockButton.clipsToBounds = true
        }
        tableViewDataSource.allSpinnersUnlocked = allSpinnersPurchased
        tableView.reloadData()
        let spinsForReview = UserDefaults.standard.integer(forKey: Keys.spinsForReview)
        print(spinsForReview)
        if spins >= spinsForReview {
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set(spinsForReview + 1000, forKey: Keys.spinsForReview)
        }
    }

    @IBAction func restorePurchaseButtonTapped() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func unlockAllSpinnersTapped() {
        print("unlock tapped")
        guard let product = iapProducts.first else { return }
        purchase(product: product)
    }
    
}


// MARK: - Private functions

private extension SpinnersViewController {
    
    // MARK: - FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts()  {
        
        // Put here your IAP Products ID's
        if let productIdentifiers = NSSet(objects: Keys.purchaseAllSpinnersID) as? Set<String> {
            let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    func purchase(product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
}


// MARK: - Tableview delegate

extension SpinnersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newKey = spinnerKeys[indexPath.row]
        guard let spinner = spinners[newKey] else { return }
        switch spinner.unlockType {
        case .spin:
            if UserDefaults.standard.bool(forKey: Keys.allSpinnersPurchased) || spins >= spinner.cost {
                UserDefaults.standard.set(newKey, forKey: "spinner")
                tableView.reloadData()
                dismiss(animated: true, completion: nil)
            }
        case .review:
            break
        case .share:
            let shared = UserDefaults.standard.bool(forKey: Keys.shared)
            if shared {
                UserDefaults.standard.set(newKey, forKey: "spinner")
                tableView.reloadData()
                dismiss(animated: true, completion: nil)
            } else {
                showOkAlert(with: "Share to Unlock!", message: "To share this app just return to the main screen and click on the button in the upper left hand corner. Thank you!")
            }
        }
    }
    
}


// MARK: - Store delegates

extension SpinnersViewController: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        iapProducts = response.products
        if let product = response.products.first {
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            unlockButton.isEnabled = true
            UIView.animate(withDuration: 0.5, animations: { 
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

extension SpinnersViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            guard let transaction = transaction as? SKPaymentTransaction else { return }
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                allSpinnersPurchased = true
                UserDefaults.standard.set(true, forKey: Keys.allSpinnersPurchased)
                tableViewDataSource.allSpinnersUnlocked = allSpinnersPurchased
                headerView.isHidden = true
                headerView.frame = CGRect.zero
                tableView.reloadData()
                showOkAlert(with: "All spinners successfully purchased", message: nil)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                allSpinnersPurchased = true
                UserDefaults.standard.set(true, forKey: Keys.allSpinnersPurchased)
                tableViewDataSource.allSpinnersUnlocked = allSpinnersPurchased
                headerView.isHidden = true
                headerView.frame = CGRect.zero
                tableView.reloadData()
                showOkAlert(with: "Purchases restored", message: nil)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(error)
    }
    
    
}

