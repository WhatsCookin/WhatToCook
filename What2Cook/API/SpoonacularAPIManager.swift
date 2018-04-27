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
    
    let maxResults = 200
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/findByIngredients?ingredients=" + ingredientString + "&number=" + String(maxResults) + "&fillIngredients=true&ranking=1&limitLicense=true"
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let recipeDictionary = response.result.value as! NSArray? {
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
    
    let numResults = 100
    
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
  
  func setRecipeData(_ recipe: Recipe) {
    //let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
    
    let id = recipe.id!
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/" + String(id) + "/information"
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
      "X-Mashape-Key": key,
      ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
      if let dataDictionary = response.result.value as! NSDictionary? {
        // TODO: Initialize a RecipeData object and use recipe.setRecipeData() to store it in the recipe object
        print(dataDictionary)
      }
      else {
        print("Something went wrong")
      }
    }
  }
    
  func getPopularRecipes(completion: @escaping([RecipeItem]?, Error?) -> ()) {
    //let key = "69p5QHDqZfmshevTW4RVD0dwIh7Qp1L5vUZjsnVjlWJFfVpmAb"
    
    let numRecipes = 2 // number of popular recipes to be returned
    
    let urlstring = "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/random?number=" + String(numRecipes)
    
    //You headers (for your api key)
    let headers: HTTPHeaders = [
    "X-Mashape-Key": key,
    ]
    
    Alamofire.request(urlstring, headers: headers).responseJSON { response in
        if let recipeDictionary = response.result.value as! NSDictionary? {
            //let recipes = recipeDictionary.flatMap({ (dictionary) -> RecipeItem in RecipeItem(dictionary: dictionary as! [String : Any] )})
            let recipes = recipeDictionary["recipes"] as! [RecipeItem]
            completion(recipes, nil)
        }
        else {
            print("Something went wrong")
        }
    }
    
  }
    
}