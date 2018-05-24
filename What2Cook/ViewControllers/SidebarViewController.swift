//
//  SidebarViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class SidebarViewController: UITableViewController {
  
    var tableArray = [String]()
    
    override func viewDidLoad() {
        tableArray = ["Profile", "Bookmarks", "Logout"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[indexPath.row], for: indexPath) as UITableViewCell
      if(indexPath.row > 0) {
        cell.textLabel?.text = tableArray[indexPath.row]
      }
        return cell
    }
    
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if(tableArray[indexPath.row] == "Logout") {
    NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }
  }
}
