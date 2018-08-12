//
//  LoginViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/2/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
  
  var justRegistered = false
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var registeredLabel: UILabel!
  
  @IBAction func onSignIn(_ sender: Any) {
    let username = usernameField.text ?? ""
    let password = passwordField.text ?? ""
    
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
    
    usernameField.delegate = self
    passwordField.delegate = self
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
    if((usernameField.text?.isEmpty)! || (passwordField.text?.isEmpty)!) {
      displayError(title: "Both Fields Required", message: "Please enter your username and password")
      return false
    }
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    dismissKeyboard()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let maxLength = 15
    let currentString: NSString = textField.text! as NSString
    let newString: NSString =
      currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
}
