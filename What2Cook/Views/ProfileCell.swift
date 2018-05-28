//
//  ProfileCell.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/23/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class ProfileCell: UITableViewCell {
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    let user = PFUser.current()
    usernameLabel.text = user?.username
    self.selectionStyle = .none
    
    if let userPicture = user!.value(forKey: "profileImage") as? PFFile {
      userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
        let image = UIImage(data: imageData!)
        if image != nil {
          self.profileImageView.image = image
        }
      })
    }
    self.profileImageView.layer.cornerRadius = 30;
    self.profileImageView.layer.masksToBounds = true;
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
