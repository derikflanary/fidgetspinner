//
//  SpinnersViewController.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/30/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit

class SpinnersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

}

extension SpinnersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newKey = spinnerKeys[indexPath.row]
        UserDefaults.standard.set(newKey, forKey: "spinner")
        tableView.reloadData()
    }
    
}

