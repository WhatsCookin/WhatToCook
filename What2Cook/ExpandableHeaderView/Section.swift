//
//  Section.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class Section {
  var category: String!
  var ingredients: [String]!
  var expanded: Bool!
  var color: UIColor?
  
  init (category: String, ingredients: [String], expanded: Bool!) {
    self.category = category
    self.ingredients = ingredients
    self.expanded = expanded
  }
  
  init(d: [String : String]) {
    self.category  = d["category"]
  }
  
  public func toDictionary() -> [String: String] {
    var d = [String: String]()
    d["category"] = category
    return d
  }
}
