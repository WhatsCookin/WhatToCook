//
//  RecipeCell.swift
//  What2Cook
//
//  Created by David Tan on 4/21/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import AlamofireImage

class RecipeCell: UICollectionViewCell {
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var timeLabel: UILabel!
    //@IBOutlet weak var likesLabel: UILabel!
    //@IBOutlet weak var servingsLabel: UILabel!
    
    @IBOutlet weak var ratingsImageView: UIImageView!
    
    var recipe: RecipeItem! {
        didSet {
            if let url = URL(string: recipe.image!) {
               recipeImage.af_setImage(withURL: url)
            }
            nameLabel.text = recipe.name
            //timeLabel.text = "Time: " + String(recipe.time)
            //likesLabel.text = "Likes: " + String(recipe.likes)
            //servingsLabel.text = " Servings: " + String(recipe.servings)
        }
    }
}
