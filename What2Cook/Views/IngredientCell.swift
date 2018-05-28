//
//  IngredientCell.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation
import UIKit

class IngredientCell: UITableViewCell {
  override func awakeFromNib() {
    self.selectionStyle = .none
    self.backgroundColor = UIColor.clear
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    self.accessoryType = selected ? .checkmark : .none
  }
}
