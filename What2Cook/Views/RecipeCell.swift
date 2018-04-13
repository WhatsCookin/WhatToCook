//
//  RecipeCell.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/2/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    var recipe: Recipe! {
        didSet {
            //thumbImageView.setImageWith(recipe.imageUrl!)
            titleLabel.text = recipe.title
            authorLabel.text = recipe.author
        }
    }
}
