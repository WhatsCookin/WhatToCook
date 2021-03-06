//
//  DeleteCategoryViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/24/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class DeleteCategoryViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  var fridgeViewController: FridgeViewController?
  
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var categoryDropDown: UIPickerView!
  
  @IBAction func onBack(_ sender: UIButton) {
    self.view.removeFromSuperview()
  }
  
  @IBAction func onDelete(_ sender: UIButton) {
    let categoryName = categoryTextField.text
    if (fridgeViewController?.removeSection(name: categoryName!))! {
      self.view.removeFromSuperview()
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
    self.categoryTextField.text = chosenCategory
    self.categoryDropDown.isHidden = true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.categoryDropDown.isHidden = false
    dismissKeyboard()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    categoryTextField.text = fridgeViewController?.sections[0].category
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
  }
}
