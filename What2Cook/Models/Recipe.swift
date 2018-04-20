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
  var title: String!
  var imageType: String!
  var missedIngredients: [String]!
  var usedIngredients: [String]!
  var recipeData: RecipeData?
  
  init(dictionary: [String: Any]) {
    missedIngredientCount = dictionary["missedIngredientCount"] as? Int
    id = dictionary["id"] as? Int
    image = dictionary["image"] as? String
    usedIngredientCount = dictionary["usedIngredientCount"] as? Int
    likes = dictionary["likes"] as? Int
    title = dictionary["title"] as? String
    imageType = dictionary["imageType"] as? String
    missedIngredients = dictionary["missedIngredients"] as? [String]
    usedIngredients = dictionary["usedIngredients"] as? [String]
  }
  
  func setRecipeData(recipeData: RecipeData) {
    self.recipeData = recipeData
  }
  
  static func recipes(with array: [[String: Any]]) -> [Recipe] {
    return array.flatMap({ (dictionary) -> Recipe in
      Recipe(dictionary: dictionary)
    })
  }
}
