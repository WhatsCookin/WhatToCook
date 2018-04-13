//
//  SideMenuViewController.swift
//  What2Cook
//
//  Created by David Tan on 4/12/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class SideMenuViewController:UITableViewController {
    
    var tableArray = [String]()
    
    override func viewDidLoad() {
        tableArray = ["Profile","Bookmarks","Friends","Settings","Help","LogOut"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[indexPath.row], for: indexPath) as UITableViewCell
        cell.textLabel?.text = tableArray[indexPath.row]
        return cell
    }
    
}
