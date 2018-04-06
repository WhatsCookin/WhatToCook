//
//  FridgeViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class FridgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  // TODO: Replace placeholder data
  var sections = [
    Section(category: "Fruits",
            ingredients: ["Apple", "Peach", "Tomato"],
            expanded: false),
    Section(category: "Vegetables",
            ingredients: ["Cabbage", "Carrot"],
            expanded: false),
    Section(category: "Meat",
            ingredients: ["Chicken", "Beef"],
            expanded: false),
    Section(category: "Spices",
            ingredients: [],
            expanded: false)
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.tableView.allowsMultipleSelection = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].ingredients.count
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (sections[indexPath.section].expanded) {
      return 44 }
    else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 2
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = ExpandableHeaderView()
    header.customInit(title: sections[section].category, section: section, delegate: self)
      return header
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell")!
    cell.textLabel?.text = sections[indexPath.section].ingredients[indexPath.row]
    return cell
  }
  
  func toggleSection(header: ExpandableHeaderView, section: Int) {
    sections[section].expanded = !sections[section].expanded
    // Animate so that ingredients appear and disappear
    tableView.beginUpdates()
    for i in 0 ..< sections[section].ingredients.count {
      tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
    }
    tableView.endUpdates()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("Selected: " + sections[indexPath.section].ingredients[indexPath.row])
  }
}
