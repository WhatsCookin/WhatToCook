//
//  FridgeViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/5/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse
import Speech
import FontAwesome_swift

class FridgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, ExpandableHeaderViewDelegate {
  
  var recipesList: [Recipe] = []
  var ingredients: [String] = []
  var selectIndexPath: IndexPath!
  private var selectedAll = false
  
  @IBOutlet weak var tableView: UITableView!
  
  // All buttons using FontAwesome
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var deleteCategoryButton: UIButton!
  @IBOutlet weak var fetchRecipesButton: UIButton!
  @IBOutlet weak var moveIngredientsButton: UIButton!
  @IBOutlet weak var deleteIngredientsButton: UIButton!
  @IBOutlet weak var selectAllButton: UIButton!
  @IBOutlet weak var instructionsLabel: UILabel!
  
  // Fetch recipes with the selected ingredients
  @IBAction func onSearch(_ sender: Any) {
    if checkForSelection() {
      SpoonacularAPIManager().searchRecipes(ingredients) { (recipes) in
        if let recipes = recipes {
          if(recipes.count > 0) {
            self.recipesList = recipes
            
            // Pass recipe data to new view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let recipeSuggestionViewController = storyboard.instantiateViewController(withIdentifier: "Suggestion") as! RecipeSuggestionViewController
            recipeSuggestionViewController.recipes = self.recipesList
            
            self.navigationController?.pushViewController(recipeSuggestionViewController, animated: true)
          }
          else {
            self.displayError(title: "No Recipes Found", message: "Check that you have internet connection and that the ingredients are spelled correctly.")
          }
        }
      }
    }
  }
  
  // To check that any ingredients are selected before fetching recipes
  func checkForSelection() -> Bool {
    if(ingredients.count == 0) {
      displayError(title: "No Ingredients Selected", message: "Please select ingredients first.")
      return false
    }
    return true
  }
  
  // Select all ingredients in the fridge
  @IBAction func onSelectAll(_ sender: UIButton) {
    if !selectedAll {
      selectAll()
    }
    else {
      deselectAll()
    }
    selectedAll = !selectedAll
  }
  
  // Select all ingredients in fridge
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
  
  // Deselect all ingredients in fridge
  func deselectAll() {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as! ExpandableHeaderView
    header.tableView = tableView
    for section in 0..<sections.count {
      header.deselectSection(section: section)
    }
  }
  
  // Delete a selected ingredient
  @IBAction func onDelete(_ sender: UIButton) {
    if checkForSelection() {
      for ingredient in ingredients {
        removeIngredient(ingredient: ingredient)
      }
    }
  }
  
  // Search and remove an ingredient
  func removeIngredient(ingredient: String) {
    for i in 0..<sections.count {
      if let index = sections[i].ingredients.index(of: ingredient) {
        sections[i].ingredients.remove(at: index)
        save()
        return
      }
    }
  }
  
  // Move an ingredient to another category
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
  
  // Delete a selected category that holds ingredients
  @IBAction func onDeleteCategory(_ sender: UIButton) {
    if(sections.count == 0) {
      displayError(title: "Cannot Delete Categories", message: "You have no categories.")
    }
    else {
      let moveToCategoryVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DeleteCategory") as! DeleteCategoryViewController
      moveToCategoryVC.fridgeViewController = self
      self.addChildViewController(moveToCategoryVC)
      moveToCategoryVC.view.frame = self.view.frame
      self.view.addSubview(moveToCategoryVC.view)
      moveToCategoryVC.didMove(toParentViewController: self)
    }
  }
  
  // Array for all user-created categories that each hold an array of ingredients (Replaced by data in Parse Server)
  var sections = [
    Section(category: "Example",
            ingredients: [],
            color: UIColor.blue,
            expanded: true)
  ]
  
  // Save fridge data in Parse Server
  func save() {
    tableView.reloadData()
    let user = PFUser.current()
    let sectionsToStore = NSMutableArray.init()
    for section in sections {
      sectionsToStore.add(section.toDictionary())
    }
    user!["sections"] = sectionsToStore
    
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
  }
  
  // Load the fridge data from Parse Server
  func loadSections() {
    sections = []
    let user = PFUser.current()
    let storedSections = user?.object(forKey: "sections") as? [Dictionary<String, AnyObject>]
    
    if storedSections != nil {
      for eachSection in storedSections! {
        let section = Section(dictionary: eachSection)
        sections.append(section)
      }
    }
  }
  
  // Add an ingredient to category
  func addIngredient(ingredient: String, category: String) {
    for i in 0..<sections.count {
      if(sections[i].category == category) {
        sections[i].ingredients.append(ingredient)
        save()
        return
      }
    }
  }
  
  // Checks if ingredient with the same name has already been added
  func ingredientAlreadyAdded(ingredient: String) -> Bool {
    for i in 0..<sections.count {
      if sections[i].ingredients.index(of: ingredient) != nil {
        return true
      }
    }
    return false
  }
  
  // Add new category
  func addSection(name: String, color: UIColor) {
    if (checkCategoryExists(category: name) != -1) {
      displayError(title: "Cannot Add Category", message: "Category already exists.")
    }
    else {
      let newSection = Section(category: name, ingredients: [], color: color, expanded: false)
      sections.append(newSection)
      save()
    }
    return
  }
  
  // Checks if category with the same name has already been added
  func checkCategoryExists(category: String) -> Int {
    for i in 0..<sections.count {
      let existingCategory = sections[i].category.lowercased()  // Ignore capitalization
      if existingCategory == category.lowercased() {
        return i
      }
    }
    return -1
  }
  
  // Search and remove a category
  func removeSection(name: String) -> Bool {
    for i in 0..<sections.count {
      if sections[i].category == name {
        sections.remove(at: i)
        save()
        return true
      }
    }
    displayError(title: "No Category Chosen", message: "You must choose a category.")
    return false
  }
  
  // Move ingredients from one category to another
  func moveIngredients(ingredients: Array<String>, categoryName: String) {
    for ingredient in ingredients {
      removeIngredient(ingredient: ingredient)
      addIngredient(ingredient: ingredient, category: categoryName)
    }
    self.ingredients = []
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ingredients = []
    save()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if (sections.count == 0) {
      instructionsLabel.text = "Start by adding a new category!"
    }
    else if (sections.count == 1 && sections[0].ingredients.count == 0) {
      instructionsLabel.text = "Add a new ingredient to a category by\ntapping the \"+\""
    }
    else {
      instructionsLabel.isHidden = true
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = .clear
    tableView.tableFooterView = UIView()
    loadSections()
    
    hideKeyboardWhenTappedAround()
    
    selectIndexPath = IndexPath(row: -1, section: -1)
    
    let nib = UINib(nibName: "ExpandableHeaderView", bundle: nil)
    tableView.register(nib, forHeaderFooterViewReuseIdentifier: "expandableHeaderView")
    
    fixFontAwesome(button: categoryButton, title: "Add Category", icon: String.fontAwesomeIcon(name: .plus), size: 17, before: true)
    fixFontAwesome(button: deleteCategoryButton, title: "Delete Category", icon: String.fontAwesomeIcon(name: .minusCircle), size: 17, before: true)
    fixFontAwesome(button: fetchRecipesButton, title: "Fetch Recipes", icon: String.fontAwesomeIcon(name: .search), size: 30, before: true)
    fixFontAwesome(button: moveIngredientsButton, title: "Move Ingredients", icon: String.fontAwesomeIcon(name: .sort), size: 17, before: true)
    fixFontAwesome(button: deleteIngredientsButton, title: "Delete Ingredients", icon: String.fontAwesomeIcon(name: .minusCircle), size: 17, before: true)
    fixFontAwesome(button: selectAllButton, title: "Select All", icon: String.fontAwesomeIcon(name: .list), size: 17, before: false)
    
    self.tableView.allowsMultipleSelection = true
    self.tableView.delegate = self
    self.tableView.dataSource = self
  }
  
  // Fix bottom of text getting cut off
  func fixFontAwesome(button: UIButton, title: String, icon: String, size: CGFloat, before: Bool) {
    if before {
      let iconPart = NSMutableAttributedString(string: icon, attributes: [NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: size)])
      
      let textPart = NSMutableAttributedString(string: " " + title, attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: size)])
      
      iconPart.append(textPart)
      button.setAttributedTitle(iconPart, for: .normal)
    }
    else {
      let textPart = NSMutableAttributedString(string: title + " ", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: size)])
      
      let iconPart = NSMutableAttributedString(string: icon, attributes: [NSAttributedStringKey.font: UIFont.fontAwesome(ofSize: size)])
      
      textPart.append(iconPart)
      button.setAttributedTitle(textPart, for: .normal)
    }
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
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as! ExpandableHeaderView
    header.customInit(title: sections[section].category, section: section, color: sections[section].color!, delegate: self, tableView: tableView)
    return header
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell")!
    cell.textLabel?.text = sections[indexPath.section].ingredients[indexPath.row]
    return cell
  }
  
  func toggleSection(header: ExpandableHeaderView, section: Int) {
    if(sections[section].expanded) {
      header.uncheck()
      header.deselectSection(section: section)
    }
    
    sections[section].expanded = !sections[section].expanded
    // Animate so that ingredients appear and disappear
    tableView.beginUpdates()
    for i in 0 ..< sections[section].ingredients.count {
      tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
    }
    tableView.endUpdates()
  }
  
  // Add ingredient to category
  func addIngredient(header: ExpandableHeaderView, section: Int) {
    let ingredientSearchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IngredientSearch") as! IngredientSearchViewController
    ingredientSearchVC.category = sections[section].category
    ingredientSearchVC.fridgeViewController = self
    self.addChildViewController(ingredientSearchVC)
    ingredientSearchVC.view.frame = self.view.frame
    self.view.addSubview(ingredientSearchVC.view)
    ingredientSearchVC.didMove(toParentViewController: self)
  }
  
  // Check is category is expanded or collapsed
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
    dismissKeyboard()
    let ingredientSearchViewController = segue.destination as? IngredientSearchViewController
    ingredientSearchViewController?.fridgeViewController = self
    
    let categoryViewController = segue.destination as? CategoryViewController
    categoryViewController?.fridgeViewController = self
  }
}
