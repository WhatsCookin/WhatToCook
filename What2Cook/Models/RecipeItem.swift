//
//  RecipeItem.swift
//  What2Cook
//
//  Created by David Tan on 4/20/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class RecipeItem { // recipe to display - TODO: change to combine recipe and recipe item
  var id: Int!
  var image: String!
  var name: String!
  var imageType: String!
  var ingredients: [[String:Any]]! // need to parse array of meta data for ingredients
  var directions: [[String:Any]]!
  var time: Int! // combine prep and cook time
  var servings: Int!
  var likes: Int!
  var instructions: String! //parse this string to get steps
  var analyzedInstructions: [[String: Any]]
  var bookmarked: Bool!
  
  init(dictionary: [String: Any]) {
    id = dictionary["id"] as? Int
    image = dictionary["image"] as? String
    name = dictionary["title"] as? String
    imageType = dictionary["imageType"] as? String
    likes = dictionary["aggregateLikes"] as? Int
    servings = dictionary["servings"] as? Int
    time = dictionary["readyInMinutes"] as? Int
    ingredients = dictionary["extendedIngredients"] as? [[String:Any]]
    bookmarked = (dictionary["bookmarked"] as? Bool) ?? false
    analyzedInstructions = dictionary["analyzedInstructions"] as! [[String:Any]]
    if analyzedInstructions.isEmpty {
      directions = [[:]]
    }
    else {
      let firstElem = analyzedInstructions[0]
      directions = firstElem["steps"] as? [[String:Any]]
    }
  }
  
  static func recipes(with array: [[String: Any]]) -> [RecipeItem] {
    return array.flatMap({ (dictionary) -> RecipeItem in
      RecipeItem(dictionary: dictionary)
    })
  }
  
  func toDictionary() -> NSDictionary {
    print(self.name)
    return [
      "id": self.id,
      "image": self.image,
      "title": self.name,
      "imageType": self.imageType,
      "extendedIngredients": self.ingredients,
      "readyInMinutes": self.time,
      "servings": self.servings,
      "aggregateLikes": self.likes,
      "bookmarked": self.bookmarked,
      "analyzedInstructions": self.analyzedInstructions
      ] as NSDictionary
  }
}

