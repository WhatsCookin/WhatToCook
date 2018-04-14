//
//  SpoonacularAPIManager.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/13/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class SpoonacularAPIManager {
  
  func searchRecipes(_ ingredients: [String], completion: @escaping([Recipe]?, Error?) -> ()) {
    print("called searchRecipes")
    let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
    
    var ingredientString = ""
    for ingredient in ingredients {
      ingredientString += ingredient + ","
    }
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=" + ingredientString
    guard let url = URL(string: urlstring) else {return}
    
    let session = URLSession(configuration: .default)
    var request = URLRequest(url: url)
    request.setValue(key, forHTTPHeaderField: "X-Mashape-Key")
    session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
      if let error = error {
        print(error)
        completion(nil, error)
      }
      else if let data = data {
        do {
          if let recipeDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            print(recipeDictionary)
            
            let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary )})
            completion(recipes, nil)
          } else {
          }
        } catch {
            return
        }
      }
    }.resume()
  }
}
