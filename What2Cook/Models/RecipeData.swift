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
  // TODO: Store the "steps" dictionary
  
  init(dictionary: [String: Any]) {
    sourceUrl = dictionary["sourceUrl"] as? String
    spoonacularSourceUrl = dictionary["spoonacularSourceUrl"] as? String
    // TODO: Initialize the "steps" dictionary
  }
}

