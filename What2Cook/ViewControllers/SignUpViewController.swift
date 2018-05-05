//
//  SignUpViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/3/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var reenterPasswordField: UITextField!
  @IBOutlet weak var usernameField: UITextField!
  
  @IBAction func onSignUp(_ sender: UIButton) {
    // Check for errors and display error message
    
    let username = usernameField.text
    let password = passwordField.text
    let passwordCheck = reenterPasswordField.text
    
    if username == "" || password == "" || passwordCheck == "" {
      displayError(title: "Error", message: "All fields are required.")
    }
    else if password != passwordCheck {
      displayError(title: "Error", message: "Passwords do not match.")
    }
    else if (password?.count)! < 6 {
      displayError(title: "Error", message: "Password is too short. Must be at least 6 characters.")
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
        } else {
          print("Created a new user")
          // display view controller that needs to shown after successful login
          self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
      }
    }
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      self.hideKeyboardWhenTappedAround() 
      
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
