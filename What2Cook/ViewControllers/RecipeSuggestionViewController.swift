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
  var recipeItem: RecipeItem
  var recipeItems: [RecipeItem] = []
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 50
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
  func loadRecipeItems() {
    for recipe in self.recipes {
        let id = recipe.id!
        SpoonacularAPIManager().getRecipeData(id) { (data, error) in
            if let data = data {
                self.recipeItems.append(data)
            }
            else if error != nil {
                print("Error")
            }
        }
    }//end of for
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! UITableViewCell
    // Get the index path from the cell that was tapped
    if let indexPath = tableView.indexPath(for: cell) {
      let recipe = recipes[indexPath.row]
      let id = recipe.id
      //var recipeItem: RecipeItem?
      /*SpoonacularAPIManager().getRecipeData(id!) { (data, error) in
            if let data = data {
                self.recipeItem = data
                print("hi")
                print(self.recipeItem?.name)
                let singleViewController = segue.destination as! SingleViewController
                singleViewController.recipe = self.recipeItem
            }
            else if error != nil {
                print("Error")
            }
        }*/
      //getRecipeWithId(id: id!)
      print("hello")
      print(self.recipeItem.name)
      //let singleViewController = segue.destination as! SingleViewController
      //singleViewController.recipe = self.recipeItem
    }
  }
}
