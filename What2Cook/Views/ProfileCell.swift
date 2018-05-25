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
    
  @IBAction func onProfileImageTapped(_ sender: UIButton) {
    
  }
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    let user = PFUser.current()
    usernameLabel.text = user?.username
    
    if let userPicture = user!.value(forKey: "profileImage") as? PFFile {
      userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
        let image = UIImage(data: imageData!)
        if image != nil {
          self.profileImageView.image = image
        }
      })
    }
  }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
