//
//  DrawerViewController+TableView.swift
//  ShortcutsDrawer
//
//  Created by Phill Farrugia on 10/17/18.
//  Copyright © 2018 Phill Farrugia. All rights reserved.
//

import UIKit

/// An extension on DrawerViewController that handles all of the
/// tableView related configuration and functionality.
extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Configuration
    internal func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DrawerTableViewCell", bundle: nil), forCellReuseIdentifier: "DrawerTableViewCell")
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerTableViewCell", for: indexPath) as? DrawerTableViewCell {

            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DrawerTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
