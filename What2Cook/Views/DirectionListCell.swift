//
//  DirectionListCell.swift
//  What2Cook
//
//  Created by David Tan on 5/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class DirectionListCell: UITableViewCell {

    @IBOutlet weak var directionLabel: UILabel!
    
    var direction: [String:Any]! {
        didSet {
            directionLabel.text = direction["step"] as? String
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
