//
//  LoginViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/2/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

  @IBOutlet weak var usernameLabel: UITextField!
  @IBOutlet weak var passwordLabel: UITextField!
  
  @IBAction func onSignIn(_ sender: Any) {
    let username = usernameLabel.text ?? ""
    let password = passwordLabel.text ?? ""
    
    if(check()) {
      PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
        if let error = error {
          print("User log in failed: \(error.localizedDescription)")
        } else {
          print("User logged in successfully")
          // display view controller that needs to shown after successful login
          self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
      }
    }
  }
  @IBAction func onSignUp(_ sender: Any) {
    // initialize a user object
    let newUser = PFUser()
    
    // set user properties
    newUser.username = usernameLabel.text
    newUser.password = passwordLabel.text
    
    if(check()) {
      // call sign up function on the object
      newUser.signUpInBackground { (success: Bool, error: Error?) in
        if let error = error {
          print(error.localizedDescription)
        } else {
          print("User Registered successfully")
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func check() -> Bool {
    if((usernameLabel.text?.isEmpty)! || (passwordLabel.text?.isEmpty)!) {
      print("empty")
      let alertController = UIAlertController(title: "Both Fields Required", message: "Please enter your username and password", preferredStyle: .alert)
      
      // create an OK action
      let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        // handle response here.
      }
      // add the OK action to the alert controller
      alertController.addAction(OKAction)
      present(alertController, animated: true) {
        // optional code for what happens after the alert controller has finished presenting
      }
      return false
    }
    return true
  }
}
