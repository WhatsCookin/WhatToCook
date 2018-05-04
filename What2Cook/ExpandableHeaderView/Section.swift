//
//  Section.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

struct Section {
  var category: String!
  var ingredients: [String]!
  var expanded: Bool!
  
  init (category: String, ingredients: [String], expanded: Bool!) {
    self.category = category
    self.ingredients = ingredients
    self.expanded = expanded
  }
  
  /*mutating func update (ingredients: [String], expanded: Bool!) {
    self.ingredients = ingredients
    self.expanded = expanded
  }*/
}
