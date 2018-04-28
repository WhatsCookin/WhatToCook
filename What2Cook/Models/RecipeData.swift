//
//  RecipeData.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/20/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class RecipeData {
  var sourceUrl: String!
  var spoonacularSourceUrl: String!
  var analyzedInstructions: [[String: Any]]!
  var stepsArray: [String] = []
  
  init(dictionary: [String: Any]) {
    sourceUrl = dictionary["sourceUrl"] as? String
    spoonacularSourceUrl = dictionary["spoonacularSourceUrl"] as? String
    analyzedInstructions = dictionary["analyzedInstructions"] as? [[String: Any]]
    let firstElemAnalyzed = analyzedInstructions[0]
    let steps = firstElemAnalyzed["steps"] as! [[String: Any]]
    
    for i in 0...steps.count - 1 {
      let firstElemSteps = steps[i]
      let stringStep = firstElemSteps["step"] as! String
      stepsArray.append(stringStep)
    }
  }
}

