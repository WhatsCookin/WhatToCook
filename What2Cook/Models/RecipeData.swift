//
//  RecipeData.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/20/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class RecipeData {
  var sourceUrl: String!
  var spoonacularSourceUrl: String!
  
  init(dictionary: [String: Any]) {
    sourceUrl = dictionary["sourceUrl"] as? String
    spoonacularSourceUrl = dictionary["spoonacularSourceUrl"] as? String
  }
  
  static func recipes(with array: [[String: Any]]) -> [Recipe] {
    return array.flatMap({ (dictionary) -> Recipe in
      Recipe(dictionary: dictionary)
    })
  }
}

