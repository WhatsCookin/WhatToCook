//
//  Food2ForkAPIManager.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/9/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation
import Alamofire

class Food2ForkAPIManager {
  let searchUrl = "http://food2fork.com/api/search?key=84a7ad6ab8b00caae48359b7a8b980d6&q="
  
  func searchRecipes(_ ingredientString: String, completion: @escaping([Recipe]?, Error?) -> ()) {
    var recipes: [Recipe] = []
    
    let urlString = searchUrl + ingredientString
    request(urlString, method: .post, encoding: URLEncoding.queryString).validate().responseJSON { (response) in
      if response.result.isSuccess,
      let dictionary = response.result.value as? [String: Any] {
        let recipeDictionary = dictionary["recipes"] as! NSArray
        
        //let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary)})
        
        for element in recipeDictionary {
          let recipe = Recipe(dictionary: element as! [String : Any])
          recipes.append(recipe)
        
         }
        completion(recipes, nil)
      }
      else {
        completion(nil, response.result.error)
      }
    }
  }
}
