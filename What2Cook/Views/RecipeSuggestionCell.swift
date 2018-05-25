//
//  RecipeSuggestionCell.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import AlamofireImage

class RecipeSuggestionCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var missedIngredientLabel: UILabel!
  
  var recipe: Recipe! {
    didSet {
      //titleLabel.text = recipe.title
      titleLabel.text = recipe.name
      if let url = URL(string: recipe.image!) {
        photoImageView.af_setImage(withURL: url)
      }
      if(recipe.missedIngredientCount == 0) {
        missedIngredientLabel.text = "You have everything you need"
      }
      else if(recipe.missedIngredientCount == 1) {
        missedIngredientLabel.text = "You need 1 more ingredient"
      }
      else if(recipe.missedIngredientCount > 1) {
        missedIngredientLabel.text = "You need " + String(recipe.missedIngredientCount) + " more ingredients"
      }
    }
  }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
