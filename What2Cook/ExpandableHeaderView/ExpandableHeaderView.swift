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
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)

}

class ExpandableHeaderView: UITableViewHeaderFooterView {
  var delegate: ExpandableHeaderViewDelegate?
  var section: Int!
  var tableView: UITableView?
  
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var checkbox: UIButton!
  @IBOutlet var view: ExpandableHeaderView!
  
  @IBAction func onCheck(_ sender: UIButton) {
    // Expand view if not already expanded
    if !((delegate?.isExpanded(header: self, section: section))!) {
      delegate?.toggleSection(header: self, section: section)
    }
    
    // Select or deselect all rows
    if(!sender.isSelected) {
      selectSection(section: section)
    }
    else {
      deselectSection(section: section)
    }
    sender.isSelected = !sender.isSelected
  }
  
  func selectSection(section: Int) {
    let numRows = (tableView?.numberOfRows(inSection: section))!
    if numRows > 0 {
      for i in 0...numRows - 1 {
        let indexPath = IndexPath(row: i, section: section)
        tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        tableView?.delegate?.tableView!(tableView!, didSelectRowAt: indexPath)
      }
    }
  }
  
  func deselectSection(section: Int) {
    let numRows = (tableView?.numberOfRows(inSection: section))!
    if numRows > 0 {
      for i in 0...numRows - 1 {
        let indexPath = IndexPath(row: i, section: section)
        tableView?.deselectRow(at: indexPath, animated: true)
        tableView?.delegate?.tableView!(tableView!, didDeselectRowAt: indexPath)
      }
    }
  }
  
  /*func selectAll(numberOfSections: Int) {
    for section in 0..<numberOfSections {
      selectSection(section: section)
    }
  }
  
  func deselectAll(numberOfSections: Int) {
    for section in 0..<numberOfSections {
      deselectSection(section: section)
    }
  }*/
  
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
  
  func customInit(title: String, section: Int, color: UIColor, delegate: ExpandableHeaderViewDelegate, tableView: UITableView) {
    self.categoryLabel?.text = title
    self.view.backgroundColor = color
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
