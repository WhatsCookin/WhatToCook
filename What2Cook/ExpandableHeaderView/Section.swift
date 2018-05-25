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
    let hashcolor = dictionary["color"] as! String
    color = hashStringToColor(string: hashcolor)
    //color = dictionary["color"]. as! UIColor
    expanded = dictionary["expanded"] as! Bool
  }
  
  func toDictionary() -> NSDictionary {
    return [
      "category": self.category,
      "ingredients": self.ingredients,
      "color": String(self.color.hashValue),
      "expanded": self.expanded,
      ] as NSDictionary
  }
  
  func hashStringToColor(string: String) -> UIColor {
    let hash: Int = string.hashValue
    let r: Int = (hash & 0xFF0000) >> 16
    let g: Int = (hash & 0x00FF00) >> 8
    let b: Int = (hash & 0x0000FF)
    return rgbaToUIColor(r: r, g: g, b: b, a: 1.0)
  }
  
  func rgbaToUIColor(r: Int, g: Int, b: Int, a: Float) -> UIColor {
    let floatRed = CGFloat(r) / 255.0
    let floatGreen = CGFloat(g) / 255.0
    let floatBlue = CGFloat(b) / 255.0
    return UIColor(red: floatRed, green: floatGreen, blue: floatBlue, alpha: 1.0)
  }
}
