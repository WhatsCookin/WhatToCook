//
//  RecipeSingleView.swift
//  What2Cook
//
//  Created by David Tan on 4/21/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class RecipeSingleView: UIView {
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    
    @IBOutlet weak var ratingsImageView: UIImageView!
    
    var recipe: RecipeItem! {
        didSet {
            recipeImage.setImageWith(recipe.image)
            nameLabel.text = recipe.name
            timeLabel.text = recipe.time
            likesLabel.text = recipe.likes
            servingsLabel.text = recipe.servings
        }
    }
    
    
}
