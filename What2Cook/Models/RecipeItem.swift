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
    var time: Int! // combine prep and cook time
    var servings: Int!
    var likes: Int!
    
    var instructions: String! //parse this string to get steps
    
    init(dictionary: [String: Any]) {
        id = dictionary["id"] as? Int
        image = dictionary["image"] as? String
        name = dictionary["title"] as? String
        imageType = dictionary["imageType"] as? String
        likes = dictionary["aggregateLikes"] as? Int
        servings = dictionary["servings"] as? Int
        ingredients = dictionary["extendedIngredients"] as? [[String:Any]]
    }
    
    static func recipes(with array: [[String: Any]]) -> [RecipeItem] {
        return array.flatMap({ (dictionary) -> RecipeItem in
            RecipeItem(dictionary: dictionary)
        })
    }
    
}
