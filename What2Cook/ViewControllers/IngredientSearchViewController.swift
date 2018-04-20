//
//  IngredientSearchViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class IngredientSearchViewController: UIViewController, UITextFieldDelegate {
  
  var fridgeViewController: FridgeViewController?
  
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textLabel: UILabel!
  
  @IBAction func onAdd(_ sender: UIButton) {
    let ingredientToAdd = textField.text!
    print(textField.text!)
    SpoonacularAPIManager().autocompleteIngredientSearch(ingredientToAdd) { (ingredients, error) in
      if ingredients!.count > 0 {
        self.textLabel.text = "Added " + self.textField.text!
        self.fridgeViewController?.addIngredient(ingredient: ingredientToAdd)
      }
      else {
        print("failed")
        self.textLabel.text = "Ingredient not found"
      }
    }
  }
  
  //TODO: Force correct capitalization - every word must be capitalized
  /*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    var text = textField.text
    if(text == "" || self.textField.text?.last == " ") {
      text?.append(string.uppercased())
      return false
    }
    return true
  }*/
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.textField.delegate = self
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
