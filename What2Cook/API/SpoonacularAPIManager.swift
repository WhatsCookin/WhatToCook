//
//  SpoonacularAPIManager.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation
import Alamofire

class SpoonacularAPIManager {
  let searchUrl = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients"
  
  func searchRecipes(_ ingredientString: String, completion: @escaping([Recipe]?, Error?) -> ()) {
    
    let servicePath = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?fillIngredients=false&ingredients=apples%2Cflour%2Csugar&limitLicense=false&number=5&ranking=1"
    
    let requestParams = ""
    let someRequest = Alamofire.request(.POST, servicePath, parameters: requestParams, encoding: .JSON)
    debugPrint(someRequest)
  }
  
  /*func searchRecipes(_ ingredientString: String, completion: @escaping([Recipe]?, Error?) -> ()) {
    //var recipes: [Recipe] = []
    
    let urlString = searchUrl + ingredientString
    request(urlString, method: .post, encoding: URLEncoding.queryString).validate().responseJSON { (response) in
      if response.result.isSuccess,
        let dictionary = response.result.value as? [String: Any] {
        let recipeDictionary = dictionary["recipes"] as! NSArray
        
        let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary as! [String : Any])})
        
        /*for element in recipeDictionary {
         let recipe = Recipe(dictionary: element as! [String : Any])
         recipes.append(recipe)
         
         }*/
        completion(recipes, nil)
      }
      else {
        completion(nil, response.result.error)
      }
    }
  }*/
}
