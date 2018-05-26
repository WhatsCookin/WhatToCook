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
  var color: UIColor!
  var expanded: Bool!
  
  init (category: String, ingredients: [String], color: UIColor, expanded: Bool!) {
    self.category = category
    self.ingredients = ingredients
    self.color = color
    self.expanded = expanded
  }
  
  init (dictionary: [String: Any]) {
    category = dictionary["category"] as! String
    ingredients = dictionary["ingredients"] as! [String]
    let hex = dictionary["color"] as! String
    color = UIColor(hexString: hex)
    expanded = dictionary["expanded"] as! Bool
  }
  
  func toDictionary() -> NSDictionary {
    return [
      "category": self.category,
      "ingredients": self.ingredients,
      "color": color.htmlRGBaColor,
      "expanded": self.expanded,
      ] as NSDictionary
  }
}
