//
//  ProfileViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/16/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      let currentUser = PFUser.current()
      nameLabel.text = currentUser?.username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
