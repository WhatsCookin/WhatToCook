//
//  SignUpViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/3/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {
  let MIN_PASSWORD_LEN = 6
  
  var justRegistered = false
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var reenterPasswordField: UITextField!
  @IBOutlet weak var usernameField: UITextField!
  
  @IBAction func onSignUp(_ sender: UIButton) {
    let username = usernameField.text
    let password = passwordField.text
    let passwordCheck = reenterPasswordField.text
    
    // Check for errors and display error message
    if username == "" || password == "" || passwordCheck == "" {
      displayError(title: "Error", message: "All fields are required.")
    }
    else if password != passwordCheck {
      displayError(title: "Error", message: "Passwords do not match.")
    }
    else if (password?.count)! < MIN_PASSWORD_LEN {
      displayError(title: "Error", message: "Password is too short. Must be at least " + String(MIN_PASSWORD_LEN) + " characters.")
    }
    else {
      let newUser = PFUser()
      newUser.username = usernameField.text
      newUser.password = passwordField.text
      
      newUser.signUpInBackground { (success: Bool, error: Error?) in
        if let error = error {
          print(error.localizedDescription)
          if(error._code == 202) {
            self.displayError(title: "That Username is Taken", message: "Try a different username.")
          }
        }
        else {
          print("Created a new user")
          self.justRegistered = true
          self.navigationController?.viewControllers.remove(at: 0)
          self.performSegue(withIdentifier: "loginViewSegue", sender: self)
        }
      }
    }
  }
  
  @IBAction func goBack(_ sender: Any) {
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController {
      present(vc, animated: true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.hideKeyboardWhenTappedAround() 
    usernameField.delegate = self
    passwordField.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    return justRegistered
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let loginViewController = segue.destination as? LoginViewController
    loginViewController?.justRegistered = true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let maxLength = 15
    let currentString: NSString = textField.text! as NSString
    let newString: NSString =
      currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
}
