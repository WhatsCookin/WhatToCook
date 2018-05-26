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
    
  let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
    
  func searchRecipes(_ ingredients: [String], completion: @escaping([Recipe]?, Error?) -> ()) {
    //let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
    
    var ingredientString = ""
    for ingredient in ingredients {
      let noSpaceIngredient = ingredient.replacingOccurrences(of: " ", with: "%20")
      ingredientString += noSpaceIngredient + ","
    }
    
    let maxResults = 3
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=" + ingredientString + "&number=" + String(maxResults) + "&fillIngredients=true&ranking=1&limitLicense=true"
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! NSArray? {
        print(recipeDictionary)
        let recipes = recipeDictionary.flatMap({ (dictionary) -> Recipe in Recipe(dictionary: dictionary as! [String : Any] )})
      completion(recipes, nil)
      }
      else {
        print("Something went wrong")
      }
    }
  }
  
  func autocompleteIngredientSearch(_ searchString: String, completion: @escaping([Ingredient]?, Error?) -> ()) {
    //let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
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
                urlstring = urlstring + tags[i]
                if (i>0 && i<tags.count-1) {
                    urlstring = urlstring + "%2C"
                }
            }
        }
        
        print(urlstring)
        
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
                completion(recipes, nil)
            }
            else {
                print("Something went wrong")
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
                //print(recipes)
                completion(recipe, nil)
            }
            else {
                print("Something went wrong")
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
            else {
                print("Something went wrong")
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
                completion(joke, nil)
            }
            else {
                print("Something went wrong")
            }
        }
    }
    
    
    
}
