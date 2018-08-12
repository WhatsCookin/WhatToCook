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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let singleViewController = storyboard.instantiateViewController(withIdentifier: "SingleView") as! SingleViewController
    
    let recipe = recipes[indexPath.row]
    let id = recipe.id
    
    fetchRecipes(id: id!, completion: { (recipeItem) in
      print(recipeItem.name)
      print("completed")
      singleViewController.recipe = self.recipeItem
      self.navigationController?.pushViewController(singleViewController, animated: true)
    })
  }
  
  func fetchRecipes(id: Int, completion: @escaping (_ value: RecipeItem)->()) {
    SpoonacularAPIManager().getRecipeData(id) { (data) in
      if let data = data {
        print(data)
        self.recipeItem = data
        
        self.finishedLoading = true
        print("Loaded the data from api")
        completion(data)
      }
    }
  }
}
