//
//  RecipeSuggestionViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class RecipeSuggestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var recipes: [Recipe]!
  var recipeItem: RecipeItem?
  var finishedLoading: Bool? //api call finished
    
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 50
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    finishedLoading = false
    
    // Do any additional setup after loading the view.
    tableView.dataSource = self
    tableView.delegate = self
    
    tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.rowHeight = 100;
    tableView.estimatedRowHeight = 100
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recipes.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeSuggestionCell", for: indexPath) as! RecipeSuggestionCell
    
    cell.recipe = recipes[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  // Pass recipeitem data to single vc
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let singleViewController = segue.destination as! SingleViewController
    singleViewController.recipe = self.recipeItem
  }
    
  // Load data and check to make sure api call finishes before allowing segue
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "detailsSegue" {
        let cell = sender as! UITableViewCell
        // Get the index path from the cell that was tapped
        if let indexPath = tableView.indexPath(for: cell) {
            let recipe = recipes[indexPath.row]
            let id = recipe.id
            
            SpoonacularAPIManager().getRecipeData(id!) { (data, error) in
                if let data = data {
                    self.recipeItem = data
                    
                    self.finishedLoading = true
                    print("Loaded the data from api")
                }
                else if error != nil {
                    print("Error")
                }
            }
            
            if !finishedLoading! {
                print("Did not finish call yet")
                return false
            }
            return true
            //print("Finished call")
        }//end of cell
        
    }//end of detailssegue block
    return false
  }
    
    
}
