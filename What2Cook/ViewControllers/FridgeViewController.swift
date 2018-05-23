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
  var selectIndexPath: IndexPath!
  
  @IBOutlet weak var tableView: UITableView!
  @IBAction func onSearch(_ sender: Any) {
    if checkForSelection() {
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
  }
  @IBAction func onSelectAll(_ sender: UIButton) {
    if sender.titleLabel?.text == "Select All" {
      selectAll()
      sender.setTitle("Deselect All", for: .normal)
    }
    else {
      deselectAll()
      sender.setTitle("Select All", for: .normal)
    }
  }
  
  @IBAction func onDelete(_ sender: UIButton) {
    if checkForSelection() {
      for ingredient in ingredients {
        removeIngredient(ingredient: ingredient)
      }
      ingredients = []
    }
  }
  
  @IBAction func onMove(_ sender: UIButton) {
    if checkForSelection() {
      let moveToCategoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MoveToCategory") as! MoveToCategoryViewController
      moveToCategoryVC.fridgeViewController = self
      self.addChildViewController(moveToCategoryVC)
      moveToCategoryVC.view.frame = self.view.frame
      self.view.addSubview(moveToCategoryVC.view)
      moveToCategoryVC.didMove(toParentViewController: self)
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
  
  func checkForSelection() -> Bool {
    if(ingredients.count == 0) {
      displayError(title: "No Ingredients Selected", message: "Please select ingredients first.")
      return false
    }
    return true
  }
  
  func addIngredient(ingredient: String) {
    addIngredient(ingredient: ingredient, category: "Unlisted")
  }
  
  func addIngredient(ingredient: String, category: String) {
    for i in 0...sections.count - 1 {
      if(sections[i].category == category) {
        sections[i].ingredients.append(ingredient)
        tableView.reloadData()
        return
      }
    }
  }
  
  func removeIngredient(ingredient: String) {
    for i in 0...sections.count - 1 {
      let size = sections[i].ingredients.count - 1
      if(size >= 0) {
        for j in 0...size {
          var ingredients = sections[i].ingredients
          if ingredients![j] == ingredient {
            sections[i].ingredients.remove(at: j)
            tableView.reloadData()
            return
          }
        }
      }
    }
  }
  
  func ingredientAlreadyAdded(ingredient: String) -> Bool {
    for i in 0...sections.count - 1 {
      let ingredients = sections[i].ingredients
      if ingredients!.count > 0 {
        for j in 0...(ingredients?.count)! - 1 {
          let currentIngredient = ingredients![j]
          if currentIngredient == ingredient {
            return true
          }
        }
      }
    }
    return false
  }
  
  func addSection(name: String) {
    let newSection = Section(category: name, ingredients: [], expanded: false)
    sections.append(newSection)
    tableView.reloadData()
    return
  }
  
  func moveIngredients(ingredients: Array<String>, categoryName: String) {
    for ingredient in ingredients {
      removeIngredient(ingredient: ingredient)
      addIngredient(ingredient: ingredient, category: categoryName)
    }
  }
  
  func deselectAll() {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as! ExpandableHeaderView
    header.tableView = tableView
    for section in 0..<sections.count {
      header.deselectSection(section: section)
    }
  }
  
  func selectAll() {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as! ExpandableHeaderView
    header.tableView = tableView
    for section in 0..<sections.count {
      if !isExpanded(header: header, section: section) {
        toggleSection(header: header, section: section)
      }
      header.selectSection(section: section)
    }
  }
    
    override func viewDidLoad() {
    super.viewDidLoad()
    
    selectIndexPath = IndexPath(row: -1, section: -1)
    
    let nib = UINib(nibName: "ExpandableHeaderView", bundle: nil)
    tableView.register(nib, forHeaderFooterViewReuseIdentifier: "expandableHeaderView")
    
    // Do any additional setup after loading the view.
    self.tableView.allowsMultipleSelection = true
    self.tableView.delegate = self
    self.tableView.dataSource = self
    
    // FOR TESTING
/*    SpoonacularAPIManager().getRecipeInformation(479101) { (ingredients, error) in
      if let ingredients = ingredients {
      }
      print(ingredients)
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
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 58
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
    //let header = ExpandableHeaderView()
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as! ExpandableHeaderView
    header.customInit(title: sections[section].category, section: section, delegate: self, tableView: tableView)
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
  
  func isExpanded(header: ExpandableHeaderView, section: Int) -> Bool {
    return sections[section].expanded
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let ingredientName = sections[indexPath.section].ingredients[indexPath.row]
    ingredients.append(ingredientName)
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    let ingredientName = sections[indexPath.section].ingredients[indexPath.row]
    if let index = ingredients.index(of: ingredientName) {
      ingredients.remove(at: index)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    deselectAll()
    let ingredientSearchViewController = segue.destination as? IngredientSearchViewController
    ingredientSearchViewController?.fridgeViewController = self
    
    let categoryViewController = segue.destination as? CategoryViewController
    categoryViewController?.fridgeViewController = self
  }
}
