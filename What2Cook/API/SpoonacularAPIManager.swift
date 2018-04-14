//
//  SpoonacularAPIManager.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/13/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation
import Alamofire

class SpoonacularAPIManager {  
  func searchRecipes(_ ingredients: [String], completion: @escaping([Recipe]?, Error?) -> ()) {
    let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
    
    var ingredientString = ""
    for ingredient in ingredients {
      ingredientString += ingredient + ","
    }
    
    let maxResults = 200
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=" + ingredientString + "&number=" + String(maxResults) + "&fillIngredients=true&ranking=2"
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! NSArray? {
        let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary as! [String : Any] )})
      completion(recipes, nil)
      }
    }
  }
}
