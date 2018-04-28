//
//  RecipeViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController {
  
  var recipe: Recipe!
  @IBOutlet weak var instructionsLabel: UILabel!
  @IBOutlet weak var recipeTitleLabel: UILabel!
  @IBOutlet weak var recipeImageView: UIImageView!
  
  // Temporarily added
  @IBAction func onRefresh(_ sender: UIButton) {
    print("Refresh")
    printInstructions()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    recipeTitleLabel.text = recipe.title
    let imageUrl = URL(string: recipe.image)
    recipeImageView.af_setImage(withURL: imageUrl!)
    
    print("View did load, but RecipeData is not initialized yet")
    // At this time, the RecipeData object is nil because the view loads before RecipeData is
    // initialized from the API call. The code below will cause a crash.
    //printInstructions()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func printInstructions() {
    var instructionsText = ""
    for i in 0...recipe.recipeData!.stepsArray.count - 1 {
      instructionsText += "Step " + String(i + 1) + ": " + recipe.recipeData!.stepsArray[i] + "\n\n"
    }
    instructionsLabel.text = instructionsText
  }
}
