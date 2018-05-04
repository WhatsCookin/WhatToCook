//
//  IngredientSearchViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class IngredientSearchViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  var fridgeViewController: FridgeViewController?
  
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var categoryDropDown: UIPickerView!
  
  @IBAction func onAdd(_ sender: UIButton) {
    let ingredientToAdd = textField.text!.capitalized
    print(textField.text!)
    SpoonacularAPIManager().autocompleteIngredientSearch(ingredientToAdd) { (ingredients, error) in
      if ingredients!.count > 0 {
        self.textLabel.text = "Added " + self.textField.text!
        
        if self.categoryTextField.text != "" {
          let categoryToAddIn = self.categoryTextField.text
          self.fridgeViewController?.addIngredient(ingredient: ingredientToAdd, category: categoryToAddIn!)
        }
        else {
          self.fridgeViewController?.addIngredient(ingredient: ingredientToAdd)
        }
      }
      else {
        print("failed")
        self.textLabel.text = "Ingredient not found"
      }
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    let rowCount = fridgeViewController?.sections.count
    return rowCount!
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let rowTitle = fridgeViewController?.sections[row].category
    return rowTitle
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let chosenCategory = self.fridgeViewController?.sections[row].category
    if chosenCategory == "Unlisted" {
      self.categoryTextField.text = ""
    }
    else {
      self.categoryTextField.text = chosenCategory
    }
    self.categoryDropDown.isHidden = true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if(textField == categoryTextField) {
      self.categoryDropDown.isHidden = false
      dismissKeyboard()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.textField.delegate = self
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
