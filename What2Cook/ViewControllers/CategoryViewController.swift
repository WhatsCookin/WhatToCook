//
//  CategoryViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/2/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITextFieldDelegate {
  
  // RRGGBB hex colors in the same order as the image
  let colorArray = [ 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7 ,0x00c3ff, 0x0083ff, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199 ]
  
  @IBOutlet weak var selectedColorView: UIView!
  @IBOutlet weak var slider: UISlider!
  @IBAction func sliderChanged(_ sender: Any) {
    selectedColorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])
  }
  
  func uiColorFromHex(rgbValue: Int) -> UIColor {
    
    let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
    let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
    let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
    let alpha = CGFloat(1.0)
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  var fridgeViewController: FridgeViewController?
  @IBOutlet weak var categoryTextField: UITextField!
  
  @IBAction func onAdd(_ sender: UIButton) {
    let categoryName = categoryTextField.text
    if(categoryName != "") {
      fridgeViewController?.addSection(name: categoryName!, color: selectedColorView.backgroundColor!)
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    hideKeyboardWhenTappedAround()
    categoryTextField.delegate = self
    
    // Do any additional setup after loading the view.
    selectedColorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    dismissKeyboard()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let maxLength = 20
    let currentString: NSString = textField.text! as NSString
    let newString: NSString =
      currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
}
