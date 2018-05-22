//
//  ProfileViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/16/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var editedImage : UIImage?
  var window: UIWindow?
  @IBOutlet weak var profileImageView: UIImageView!
  
  
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBAction func onSetProfilePicture(_ sender: UIButton) {
    /*let vc = UIImagePickerController()
    vc.delegate = self
    vc.allowsEditing = true
    vc.sourceType = UIImagePickerControllerSourceType.camera
    
    self.present(vc, animated: true, completion: nil)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      print("Camera is available 📸")
      vc.sourceType = .camera
    } else {
      print("Camera 🚫 available so we will use photo library instead")
      vc.sourceType = .photoLibrary
    }*/
    
    let vc = UIImagePickerController()
    vc.delegate = self
    vc.allowsEditing = true
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      print("Camera is available 📸")
      vc.sourceType = .camera
    } else {
      print("Camera 🚫 available so we will use photo library instead")
      vc.sourceType = .photoLibrary
    }
    self.present(vc, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      let currentUser = PFUser.current()
      nameLabel.text = currentUser?.username
    }
  
  func imagePickerController(_ picker: UIImagePickerController,
  didFinishPickingMediaWithInfo info: [String : Any]) {
  // Get the image captured by the UIImagePickerController
  let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
  editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
  
  // Do something with the images (based on your use case)
  profileImageView.image = editedImage
  
  // Dismiss UIImagePickerController to go back to your original view controller
  dismiss(animated: true, completion: nil)
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
