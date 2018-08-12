//
//  SpoonacularAPIManager.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/13/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation
import Alamofire
import Parse

class SpoonacularAPIManager {
  let key = Constants().key
  
  // Retrieves recipes given a search query of ingredients
  func searchRecipes(_ ingredients: [String], completion: @escaping([Recipe]?) -> ()) {
    var ingredientString = ""
    for ingredient in ingredients {
      let noSpaceIngredient = ingredient.replacingOccurrences(of: " ", with: "%20")
      ingredientString += noSpaceIngredient + ","
    }
    
    let user = PFUser.current()
    let maxResults = user!["fridgeResults"] as! Int
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=" + ingredientString + "&number=" + String(maxResults) + "&fillIngredients=true&ranking=1&limitLicense=true"
    
    let headers: HTTPHeaders = ["X-Mashape-Key": key]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as? NSArray {
        let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary as! [String : Any] )})
        self.save(numResults: maxResults)
        completion(recipes)
      }
      else {
        completion(nil)
      }
    }
  }
  
  func autocompleteIngredientSearch(_ searchString: String, completion: @escaping([Ingredient]?) -> ()) {
    let numResults = 1
    
    let noSpaceSearchString = searchString.replacingOccurrences(of: " ", with: "%20")
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/autocomplete?query=" + noSpaceSearchString + "&number=" + String(numResults)
    
    let headers: HTTPHeaders = ["X-Mashape-Key": key]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let ingredientDictionary = response.result.value as! NSArray? {
        let ingredients = ingredientDictionary.flatMap({ (dictionary) -> Ingredient in Ingredient(dictionary: dictionary as! [String : Any] )})
        self.save(numResults: numResults)
        completion(ingredients)
      }
      else {
        completion(nil)
      }
    }
  }
  
  // Retrieves the most popular recipes
  func getPopularRecipes(_ tagString: String, completion: @escaping([RecipeItem]?) -> ()) {
    
    if let user = PFUser.current() {
      let numRecipes = user["homeResults"]! // number of popular recipes to be returned
      
      let tags = tagString.components(separatedBy:",") as [String]
      
      var urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/random?number=" + String(describing: numRecipes)
      
      if tags.count > 0 {
        urlstring = urlstring + "&tags="
        
        for i in 0...tags.count-1 {
          urlstring = urlstring + tags[i]
          if (tags.count>1 && i<tags.count-1) {
            urlstring = urlstring + "%2C"
          }
        }
      }
      
      let headers: HTTPHeaders = ["X-Mashape-Key": key]
      
      Alamofire.request(urlstring, headers: headers).responseJSON { response in
        if let recipeDictionary = response.result.value as? [String: Any] {
          if let recipeArray = recipeDictionary["recipes"] as? NSArray {
            let recipes = recipeArray.flatMap({ (dictionary) -> RecipeItem in
              RecipeItem(dictionary: dictionary as! [String: Any])
            })
            self.save(numResults: numRecipes as! Int)
            completion(recipes)
          }
        }
        else {
          completion(nil)
        }
      }
    }
  }
  
  // Retrieves the data which includes ingredients and directions of a recipe given an id
  func getRecipeData(_ id: Int, completion: @escaping(RecipeItem?) -> ()) {
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/" + String(id) + "/information"
    
    let headers: HTTPHeaders = ["X-Mashape-Key": key]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! [String:Any]? {
        let recipe = RecipeItem(dictionary: recipeDictionary )
        self.save(numResults: 1)
        completion(recipe)
      }
      else {
        completion(nil)
      }
    }
  }
  
  // Gets a random food fun fact
  func getJoke(completion: @escaping(String?) -> ()) {
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/trivia/random"
    
    let headers: HTTPHeaders = ["X-Mashape-Key": key]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      let jokeDictionary = response.result.value as? [String:Any]
      if let joke = jokeDictionary!["text"] as? String {
        self.save(numResults: 1)
        completion(joke)
      }
      else {
        print("Could not retrieve food joke")
        completion(nil)
      }
    }
  }
  
  func save(numResults: Int) {
    if let user = PFUser.current() {
      // Store number of API calls
      var numberOfCalls = user["apiCalls"] as! Int
      numberOfCalls += 1
      user["apiCalls"] = numberOfCalls
      
      // Store number of API results
      var numberOfResults = user["apiResults"] as! Int
      numberOfResults += numResults
      user["apiResults"] = numberOfResults
      
      user.saveInBackground(block: { (success, error) in
        if (success) {
          print("The user data has been saved")
        }
        else {
          print("There was a problem with saving the user data")
        }
      })
    }
  }
}
