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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    
    var gradient: CAGradientLayer = CAGradientLayer()
    
    var recipe: RecipeItem! {
        didSet {
            if let url = URL(string: recipe.image) {
               recipeImage.af_setImage(withURL: url)
            }
            nameLabel.text = recipe.name
            timeLabel.text = String(recipe.time)
            likesLabel.text = String(recipe.likes)
            servingsLabel.text = String(recipe.servings)
        }
    }
    
    override func layoutSubviews() {
        //reload images
        recipeImage.gradient(colors: [UIColor.clear.cgColor, UIColor.black.cgColor], opacity: 1, location: [0.70,1])
    }
}
extension UIImageView
{
    func gradient(colors: [CGColor], opacity: Float, location: [NSNumber]?) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.opacity = opacity
        gradientLayer.locations = location
        layer.addSublayer(gradientLayer)
    }
}
