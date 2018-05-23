//
//  Recipe.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class Recipe {
  var missedIngredientCount: Int!
  var id: Int!
  var image: String!
  var usedIngredientCount: Int!
  var likes: Int!
  var name: String!
  var imageType: String!
  var missedIngredients: [String]!
  var usedIngredients: [String]!
  
  init(dictionary: [String: Any]) {
    id = dictionary["id"] as? Int
    image = dictionary["image"] as? String
    name = dictionary["title"] as? String
    likes = dictionary["likes"] as? Int
    missedIngredients = dictionary["missedIngredients"] as? [String]
    usedIngredients = dictionary["usedIngredients"] as? [String]
  }

  static func recipes(with array: [[String: Any]]) -> [Recipe] {
    return array.flatMap({ (dictionary) -> Recipe in
      Recipe(dictionary: dictionary)
    })
  }
}
