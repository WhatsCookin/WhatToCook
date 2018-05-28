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
  static var apiCalls = 0
  let key = Constants().key
  
  func searchRecipes(_ ingredients: [String], completion: @escaping([Recipe]?, Error?) -> ()) {
    var ingredientString = ""
    for ingredient in ingredients {
      let noSpaceIngredient = ingredient.replacingOccurrences(of: " ", with: "%20")
      ingredientString += noSpaceIngredient + ","
    }
    
    let maxResults = 10
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=" + ingredientString + "&number=" + String(maxResults) + "&fillIngredients=true&ranking=2&limitLicense=true"
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! NSArray? {
        let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary as! [String : Any] )})
        SpoonacularAPIManager.apiCalls += 1
        self.save()
        completion(recipes, nil)
      }
    }
  }
  
  func autocompleteIngredientSearch(_ searchString: String, completion: @escaping([Ingredient]?, Error?) -> ()) {
    let numResults = 1
    
    let noSpaceSearchString = searchString.replacingOccurrences(of: " ", with: "%20")
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/autocomplete?query=" + noSpaceSearchString + "&number=" + String(numResults)
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let ingredientDictionary = response.result.value as! NSArray? {
        let ingredients = ingredientDictionary.flatMap({ (dictionary) -> Ingredient in Ingredient(dictionary: dictionary as! [String : Any] )})
        SpoonacularAPIManager.apiCalls += 1
        self.save()
        completion(ingredients, nil)
      }
      else {
        completion(nil, nil)
      }
    }
  }
  
  /*func ingredientExists(ingredient: String, completion: @escaping(Bool) -> ()) {
   let urlString = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/substitutes?ingredientName=" + ingredient
   
   //You headers (for your api key)
   let headers: HTTPHeaders = [
   "X-Mashape-Key": key,
   ]
   
   Alamofire.request(urlString, headers: headers).responseJSON { response in
   if let ingredientDictionary = response.result.value as! NSDictionary? {
   print(ingredientDictionary)
   let status = ingredientDictionary["status"]! as! String
   if status == "failure" {
   completion(false)
   }
   else {
   completion(true)
   }
   }
   }
   }*/
  
  // Retrieves the most popular recipes
  func getPopularRecipes(_ tagString: String, completion: @escaping([RecipeItem]?, Error?) -> ()) {
    
    
    let numRecipes = 10 // number of popular recipes to be returned
    
    let tags = tagString.components(separatedBy:",") as [String]
    
    
    var urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/random?number=" + String(numRecipes)
    
    if tags.count > 0 {
      urlstring = urlstring + "&tags="
      
      for i in 0...tags.count-1 {
        print(tags[i])
        print (i)
        urlstring = urlstring + tags[i]
        if (tags.count>1 && i<tags.count-1) {
          urlstring = urlstring + "%2C"
        }
      }
    }
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! [String: Any]? {
        let recipeArray = recipeDictionary["recipes"] as! NSArray
        let recipes = recipeArray.flatMap({ (dictionary) -> RecipeItem in
          RecipeItem(dictionary: dictionary as! [String: Any])
        })
        SpoonacularAPIManager.apiCalls += 1
        self.save()
        completion(recipes, nil)
      }
    }
  }
  
  // Retrieves the data which includes ingredients and directions of a recipe given an id
  func getRecipeData(_ id: Int, completion: @escaping(RecipeItem?, Error?) -> ()) {
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/"+String(id)+"/information"
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! [String:Any]? {
        let recipe = RecipeItem(dictionary: recipeDictionary )
        SpoonacularAPIManager.apiCalls += 1
        self.save()
        completion(recipe, nil)
      }
    }
  }
  
  // Searches for recipes based on query
  /*func queryRecipes(_ query: String, completion: @escaping(RecipeItem?, Error?) -> ()) {
   let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/search?query=" + query
   
   //You headers (for your api key)
   let headers: HTTPHeaders = [
   "X-Mashape-Key": key,
   ]
   
   Alamofire.request(urlstring, headers: headers).responseJSON { response in
   if let resultsDictionary = response.result.value as! [String:Any]? {
   let results = resultsDictionary["results"]
   
   let recipe = RecipeItem(dictionary: recipeDictionary )
   //print(recipes)
   completion(recipe, nil)
   }
   }
   }*/
  
  
  // Gets a random food fun fact
  func getJoke(completion: @escaping(String?, Error?) -> ()) {
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/trivia/random"
    
    // Headers
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let jokeDictionary = response.result.value as! [String:Any]? {
        let joke = jokeDictionary["text"] as! String
        SpoonacularAPIManager.apiCalls += 1
        self.save()
        completion(joke, nil)
      }
    }
  }
  
  func save() {
    let user = PFUser.current()
    user!["apiCalls"] = SpoonacularAPIManager.apiCalls
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
  }
}
