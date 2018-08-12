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
  
  @IBAction func onSearch(_ sender: Any) {
    if checkForSelection() {
      print(ingredients)
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
        }
        else {
          self.displayError(title: "No Recipes Found", message: "Internet connection may be unavailable. Or maybe, it's time to go shopping.")
        }
      }
    }
  }
  
  @IBAction func onSelectAll(_ sender: UIButton) {
    if !selectedAll {
      selectAll()
    }
    else {
      deselectAll()
    }
    selectedAll = !selectedAll
  }
  
  @IBAction func onDelete(_ sender: UIButton) {
    if checkForSelection() {
      for ingredient in ingredients {
        removeIngredient(ingredient: ingredient)
      }
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
  
  var sections = [
    Section(category: "Unlisted",
            ingredients: [],
            color: UIColor.blue,
            expanded: true)
  ]
  
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
  
  func clearData() {
    let user = PFUser.current()
    user!["sections"] = []
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
  }
  
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
    for i in 0..<sections.count {
      if(sections[i].category == category) {
        sections[i].ingredients.append(ingredient)
        save()
        return
      }
    }
  }
  
  func removeIngredient(ingredient: String) {
    for i in 0..<sections.count {
      if let index = sections[i].ingredients.index(of: ingredient) {
        sections[i].ingredients.remove(at: index)
        save()
        return
      }
    }
  }
  
  func ingredientAlreadyAdded(ingredient: String) -> Bool {
    for i in 0..<sections.count {
      if sections[i].ingredients.index(of: ingredient) != nil {
        return true
      }
    }
    return false
  }
  
  func checkCategoryExists(category: String) -> Int {
    for i in 0..<sections.count {
      let existingCategory = sections[i].category.lowercased()  // Ignore capitalization
      print("1 - " + existingCategory)
      print("1 - " + category.lowercased())
      if existingCategory == category.lowercased() {
        return i
      }
    }
    return -1
  }
  
  func addSection(name: String, color: UIColor) {
    let newSection = Section(category: name, ingredients: [], color: color, expanded: false)
    sections.append(newSection)
    save()
    return
  }
  
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
  
  func moveIngredients(ingredients: Array<String>, categoryName: String) {
    for ingredient in ingredients {
      removeIngredient(ingredient: ingredient)
      addIngredient(ingredient: ingredient, category: categoryName)
    }
    self.ingredients = []
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
  
  override func viewWillDisappear(_ animated: Bool) {
    ingredients = []
    save()
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
  
  func addIngredient(header: ExpandableHeaderView, section: Int) {
    let ingredientSearchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IngredientSearch") as! IngredientSearchViewController
    ingredientSearchVC.category = sections[section].category
    ingredientSearchVC.fridgeViewController = self
    self.addChildViewController(ingredientSearchVC)
    ingredientSearchVC.view.frame = self.view.frame
    self.view.addSubview(ingredientSearchVC.view)
    ingredientSearchVC.didMove(toParentViewController: self)
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
    dismissKeyboard()
    let ingredientSearchViewController = segue.destination as? IngredientSearchViewController
    ingredientSearchViewController?.fridgeViewController = self
    
    let categoryViewController = segue.destination as? CategoryViewController
    categoryViewController?.fridgeViewController = self
  }
}
