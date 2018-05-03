//
//  IngredientListCell.swift
//  What2Cook
//
//  Created by David Tan on 4/17/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class IngredientListCell: UITableViewCell {

    @IBOutlet weak var ingredientLabel: UILabel!
    
    var ingredient: [String:Any]!  {
        didSet {
            ingredientLabel.text = ingredient["originalString"] as? String
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
