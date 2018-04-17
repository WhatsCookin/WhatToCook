//
//  FridgeViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class FridgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, ExpandableHeaderViewDelegate {
  
  var recipesList: [Recipe] = []
  var ingredients: [String] = []
  
  @IBOutlet weak var tableView: UITableView!
  @IBAction func onSearch(_ sender: Any) {
    
    SpoonacularAPIManager().searchRecipes(ingredients) { (recipes, error) in
      if let recipes = recipes {
        self.recipesList = recipes
        
        // Pass recipe data to new view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let recipeSuggestionViewController = storyboard.instantiateViewController(withIdentifier: "Suggestion") as! RecipeSuggestionViewController
        recipeSuggestionViewController.recipes = self.recipesList
        self.present(recipeSuggestionViewController, animated: true, completion: nil)
        
      } else if let error = error {
        print("Error getting recipes: " + error.localizedDescription)
      }
    }
  }
  
  // TODO: Replace placeholder data
  var sections = [
    Section(category: "Unlisted",
            ingredients: ["Honey", "Bacon"],
            expanded: true),
    Section(category: "Fruits",
            ingredients: ["Apple", "Peach", "Tomato"],
            expanded: false),
    Section(category: "Vegetables",
            ingredients: ["Cabbage", "Carrot"],
            expanded: false),
    Section(category: "Meat",
            ingredients: ["Chicken", "Beef"],
            expanded: false),
    Section(category: "Spices",
            ingredients: [],
            expanded: false)
  ]
  
  func addIngredient(ingredient: String) {
    for i in 0...sections.count - 1 {
      if(sections[i].category == "Unlisted") {
        sections[i].ingredients.append(ingredient)
        tableView.reloadData()
        return
      }
    }
  }
  
  func addIngredient(ingredient: String, category: String) {
    for i in 0...sections.count - 1 {
      if(sections[i].category == category) {
        sections[i].ingredients.append(ingredient)
        tableView.reloadData()
        return
      }
    }
    print("need to create new category")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.tableView.allowsMultipleSelection = true
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    // FOR TESTING
    /*SpoonacularAPIManager().autocompleteIngredientSearch("oil") { (ingredients, error) in
      if let ingredients = ingredients {
      }
    }*/
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].ingredients.count
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (sections[indexPath.section].expanded) {
      return 44 }
    else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 2
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = ExpandableHeaderView()
    header.customInit(title: sections[section].category, section: section, delegate: self)
    return header
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell")!
    cell.textLabel?.text = sections[indexPath.section].ingredients[indexPath.row]
    return cell
  }
  
  func toggleSection(header: ExpandableHeaderView, section: Int) {
    sections[section].expanded = !sections[section].expanded
    // Animate so that ingredients appear and disappear
    tableView.beginUpdates()
    for i in 0 ..< sections[section].ingredients.count {
      tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
    }
    tableView.endUpdates()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let ingredientName = sections[indexPath.section].ingredients[indexPath.row]
    print("Selected: " + ingredientName)
    
    ingredients.append(ingredientName)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let ingredientName = sections[indexPath.section].ingredients[indexPath.row]
    if let index = ingredients.index(of: ingredientName) {
      ingredients.remove(at: index)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   let ingredientSearchViewController = segue.destination as! IngredientSearchViewController
   
   // Pass on the data to the Detail ViewController
   ingredientSearchViewController.fridgeViewController = self
   }
}
