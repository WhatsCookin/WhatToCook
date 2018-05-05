//
//  CategoryViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/2/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
  var fridgeViewController: FridgeViewController?
  @IBOutlet weak var categoryTextField: UITextField!
  
  @IBAction func onAdd(_ sender: UIButton) {
    let categoryName = categoryTextField.text
    if(categoryName != "") {
      fridgeViewController?.addSection(name: categoryName!)
      print(fridgeViewController?.sections)
      print("\n")
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
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
