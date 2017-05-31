//
//  SpinnersDataSource.swift
//  fidgetSpinner
//
//  Created by Derik Flanary on 5/30/17.
//  Copyright © 2017 Derik Flanary. All rights reserved.
//

import UIKit

class SpinnersDataSource: NSObject, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spinnerKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as SpinnerCell
        let key = spinnerKeys[indexPath.row]
        let spinner = spinners[key]
        cell.configure(with: spinner)
        guard let selectedKey = UserDefaults.standard.string(forKey: "spinner") else { return cell }
        if selectedKey == key {
            cell.backgroundColor = UIColor(red: 0.5, green: 0.69, blue: 0.86, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
}

