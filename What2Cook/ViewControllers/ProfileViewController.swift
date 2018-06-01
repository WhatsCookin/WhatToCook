//
//  ProfileViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/23/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

extension CGRect{
  init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
    self.init(x:x,y:y,width:width,height:height)
  }
  
}
extension CGSize{
  init(_ width:CGFloat,_ height:CGFloat) {
    self.init(width:width,height:height)
  }
}
extension CGPoint{
  init(_ x:CGFloat,_ y:CGFloat) {
    self.init(x:x,y:y)
  }
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  
  @IBAction func goBack(_ sender: Any) {
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController {
      present(vc, animated: true, completion: nil)
    }
  }
  
  @IBAction func onProfilePictureTapped(_ sender: UIButton) {
    let vc = UIImagePickerController()
    vc.delegate = self
    vc.allowsEditing = true
    vc.sourceType = .camera
    self.present(vc, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
    // Get the image captured by the UIImagePickerController
    let image = info[UIImagePickerControllerEditedImage] as! UIImage
    
    // Do something with the images (based on your use case)
    profileImageView.image = image
    let imageData: NSData = UIImageJPEGRepresentation(image, 1.0)! as NSData
    let imageFile: PFFile = PFFile(name:"image.jpg", data:imageData as Data)!
    do {
      try imageFile.save()
    } catch {
      
    }
    
    let user = PFUser.current()
    user?.setObject(imageFile, forKey: "profileImage")
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
    
    // Dismiss UIImagePickerController to go back to your original view controller
    dismiss(animated: true, completion: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let user = PFUser.current()
    usernameLabel.text = user!.username
    
    if let userPicture = user!.value(forKey: "profileImage") as? PFFile {
      userPicture.getDataInBackground({ (imageData: Data?, error: Error?) -> Void in
        let image = UIImage(data: imageData!)
        if image != nil {
          self.profileImageView.image = image
        }
      })
    }
    self.profileImageView.layer.cornerRadius = 26.5;
    self.profileImageView.layer.masksToBounds = true;
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
