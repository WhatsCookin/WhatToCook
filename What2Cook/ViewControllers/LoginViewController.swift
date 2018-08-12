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
  
  var justRegistered = false
  @IBOutlet weak var usernameLabel: UITextField!
  @IBOutlet weak var passwordLabel: UITextField!
  @IBOutlet weak var registeredLabel: UILabel!
  
  @IBAction func onSignIn(_ sender: Any) {
    let username = usernameLabel.text ?? ""
    let password = passwordLabel.text ?? ""
    
    if(check()) {
      PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
        if let error = error {
          print("User log in failed: \(error.localizedDescription)")
          self.displayError(title: "Couldn't Log In", message: "Wrong username or password.")
        } else {
          print("User logged in successfully")
          // display view controller that needs to shown after successful login
          self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.hideKeyboardWhenTappedAround()
    
    print("just what: " + String(justRegistered))
    
    registeredLabel.isHidden = !justRegistered
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    justRegistered = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func check() -> Bool {
    if((usernameLabel.text?.isEmpty)! || (passwordLabel.text?.isEmpty)!) {
      displayError(title: "Both Fields Required", message: "Please enter your username and password")
      return false
    }
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    dismissKeyboard()
  }
}
