//
//  CategoryViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/2/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
  
  // RRGGBB hex colors in the same order as the image
  let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
  
  @IBOutlet weak var selectedColorView: UIView!
  @IBOutlet weak var slider: UISlider!
  @IBAction func sliderChanged(_ sender: Any) {
    selectedColorView.backgroundColor = uiColorFromHex(rgbValue: colorArray[Int(slider.value)])
    print(selectedColorView.backgroundColor)
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
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
