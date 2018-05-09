//
//  ExpandableHeaderView.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
  func toggleSection(header: ExpandableHeaderView, section: Int)
  func isExpanded(header: ExpandableHeaderView, section: Int) -> Bool
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
  var delegate: ExpandableHeaderViewDelegate?
  var section: Int!
  var tableView: UITableView?
  
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var checkbox: UIButton!
  
  @IBAction func onCheck(_ sender: UIButton) {
    let numRows = (tableView?.numberOfRows(inSection: section))!
    
    // Expand view if not already expanded
    if !((delegate?.isExpanded(header: self, section: section))!) {
      delegate?.toggleSection(header: self, section: section)
    }
    
    // Select or deselect all rows
    if numRows > 0 {
      if(!sender.isSelected) {
        for i in 0...numRows - 1 {
          let indexPath = IndexPath(row: i, section: section)
          tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
      }
      else {
        for i in 0...numRows - 1 {
          let indexPath = IndexPath(row: i, section: section)
          tableView?.deselectRow(at: indexPath, animated: true)
        }
      }
    }
    sender.isSelected = !sender.isSelected
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
  }
  
  @objc func selectHeaderView(gestureRecognizer: UITapGestureRecognizer) {
    let cell = gestureRecognizer.view as! ExpandableHeaderView
    delegate?.toggleSection(header: self, section: cell.section)
  }
  
  func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate, tableView: UITableView) {
    self.categoryLabel?.text = title
    self.section = section
    self.delegate = delegate
    self.tableView = tableView
  }
  
 /* override func layoutSubviews() {
    super.layoutSubviews()
    //self.textLabel?.textColor = UIColor.white
    //self.contentView.backgroundColor = UIColor.darkGray
    // Add checkmark pic
  }*/
}
