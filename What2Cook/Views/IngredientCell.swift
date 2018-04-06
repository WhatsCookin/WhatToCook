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
  /*override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }*/
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    self.accessoryType = selected ? .checkmark : .none
  }
}
