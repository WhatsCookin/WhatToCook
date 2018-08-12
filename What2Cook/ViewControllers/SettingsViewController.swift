//
//  SettingsViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/31/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var homeResultsField: UITextField!
  @IBOutlet weak var fridgeResultsField: UITextField!
  @IBOutlet weak var apiCallsLabel: UILabel!
  @IBOutlet weak var apiResultsLabel: UILabel!
  
  @IBAction func onResetCalls(_ sender: UIButton) {
    let user = PFUser.current()
    user!["apiCalls"] = 0
    user!["apiResults"] = 0
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
    apiCallsLabel.text = "0"
    apiResultsLabel.text = "0"
  }
  
  @IBAction func onSave(_ sender: UIButton) {
    let user = PFUser.current()
    user!["homeResults"] = Int(homeResultsField.text ?? "0")
    user!["fridgeResults"] = Int(fridgeResultsField.text ?? "0")
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    homeResultsField.delegate = self
    fridgeResultsField.delegate = self
    hideKeyboardWhenTappedAround()
    
    self.homeResultsField.delegate = self
    self.fridgeResultsField.delegate = self
    
    let user = PFUser.current()
    let numberOfCalls = user!["apiCalls"]!
    let numberOfResults = user!["apiResults"]!
    apiCallsLabel.text = String(describing: numberOfCalls)
    apiResultsLabel.text = String(describing: numberOfResults)
    
    let numberOfHomeResults = user!["homeResults"]!
    let numberOfFridgeResults = user!["fridgeResults"]!
    homeResultsField.text = String(describing: numberOfHomeResults)
    fridgeResultsField.text = String(describing: numberOfFridgeResults)
  }
  
  @IBAction func goBack(_ sender: Any) {
    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as? SWRevealViewController {
      present(vc, animated: true, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let maxLength = 3
    let currentString: NSString = textField.text! as NSString
    let newString: NSString =
      currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
}
