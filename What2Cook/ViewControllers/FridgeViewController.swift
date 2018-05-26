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

class FridgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, ExpandableHeaderViewDelegate, SFSpeechRecognizerDelegate {
  
  var recipesList: [Recipe] = []
  var ingredients: [String] = []
  var selectIndexPath: IndexPath!
  private var ignoredChars = 0  // For continuous speech recognition
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  @IBOutlet weak var microphoneButton: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  @IBAction func microphoneTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      microphoneButton.isEnabled = false
    } else {
      startRecording()
    }
  }
  
  @IBAction func onSearch(_ sender: Any) {
    if checkForSelection() {
      SpoonacularAPIManager().searchRecipes(ingredients) { (recipes, error) in
        if let recipes = recipes {
          if(recipes.count > 0) {
            self.recipesList = recipes
            
            // Pass recipe data to new view
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let recipeSuggestionViewController = storyboard.instantiateViewController(withIdentifier: "Suggestion") as! RecipeSuggestionViewController
            recipeSuggestionViewController.recipes = self.recipesList
            
            self.navigationController?.pushViewController(recipeSuggestionViewController, animated: true)
          } else if let error = error {
            print("Error getting recipes: " + error.localizedDescription)
          }
        }
        else {
          self.displayError(title: "No Recipes Found", message: "Uh oh! Maybe it's time to go shopping.")
        }
      }
    }
  }
  
  @IBAction func onSelectAll(_ sender: UIButton) {
    if sender.titleLabel?.text == "Select All" {
      sender.setTitle("Deselect All", for: .normal)
      selectAll()
    }
    else {
      sender.setTitle("Select All", for: .normal)
      deselectAll()
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
    save()
  }
  
    override func viewDidLoad() {
    super.viewDidLoad()
        clearData()
      tableView.backgroundColor = .clear
      tableView.tableFooterView = UIView()
    loadSections()
      
    hideKeyboardWhenTappedAround()
    
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
      
      microphoneButton.isEnabled = false
      
      speechRecognizer?.delegate = self
      
      SFSpeechRecognizer.requestAuthorization { (authStatus) in
        
        var isButtonEnabled = false
        
        switch authStatus {
        case .authorized:
          isButtonEnabled = true
          
        case .denied:
          isButtonEnabled = false
          print("User denied access to speech recognition")
          
        case .restricted:
          isButtonEnabled = false
          print("Speech recognition restricted on this device")
          
        case .notDetermined:
          isButtonEnabled = false
          print("Speech recognition not yet authorized")
        }
        
        OperationQueue.main.addOperation() {
          self.microphoneButton.isEnabled = isButtonEnabled
        }
      }
  }
  
  func startRecording() {
    if recognitionTask != nil {
      recognitionTask?.cancel()
      recognitionTask = nil
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryRecord)
      try audioSession.setMode(AVAudioSessionModeMeasurement)
      try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
    } catch {
      print("audioSession properties weren't set because of an error.")
    }
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    let inputNode = audioEngine.inputNode
    
    guard let recognitionRequest = recognitionRequest else {
      fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
    }
    
    recognitionRequest.shouldReportPartialResults = true
    
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
      
      var isFinal = false
      
      // Start parsing voice command
      if result != nil {
        var voiceCommand = result!.bestTranscription.formattedString.substring(from: self.ignoredChars) ?? ""
        print("string: " + result!.bestTranscription.formattedString)
        
        voiceCommand = voiceCommand.replacingOccurrences(of: "Add ", with: " add ")
        voiceCommand = voiceCommand.replacingOccurrences(of: "At ", with: " add ")
        voiceCommand = voiceCommand.replacingOccurrences(of: " at ", with: " add ")
        voiceCommand = voiceCommand.replacingOccurrences(of: " to the ", with: " to ")
        voiceCommand = voiceCommand.replacingOccurrences(of: " two ", with: " to ")
        
        if (voiceCommand.range(of: " add ", options:NSString.CompareOptions.backwards) != nil) && voiceCommand.range(of: " to ", options:NSString.CompareOptions.backwards) != nil {
          // Parse Ingredient
          let addRange = voiceCommand.rangeEndIndex(toFind: " add ")
          voiceCommand = voiceCommand.substring(from: addRange)!
          let toRange = voiceCommand.rangeStartIndex(toFind: " to ")
          let ingredient = voiceCommand.substring(to: toRange)!.capitalized
          print("ingredient: " + ingredient)
          
          if !((self.ingredientAlreadyAdded(ingredient: ingredient))) {
            SpoonacularAPIManager().ingredientExists(ingredient: ingredient) { (exists) in
              if exists {
                // Parse Category
                let toEndRange = voiceCommand.rangeEndIndex(toFind: " to ")
                let category = voiceCommand.substring(from: toEndRange)!
                print("category: " + category)
                
                let categoryIndex = self.checkCategoryExists(category: category)
                if categoryIndex != -1 {
                  // Ignore capitalization
                  if !((self.ingredientAlreadyAdded(ingredient: ingredient))) {
                    self.addIngredient(ingredient: ingredient, category: self.sections[categoryIndex].category)
                  }
                  self.ignoredChars = result!.bestTranscription.formattedString.count
                }
              }
            }
          }
        }
        isFinal = (result?.isFinal)!
        
        // Attempt to reset
        self.recognitionRequest?.endAudio()
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      }
      
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.microphoneButton.isEnabled = true
      }
    })
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("audioEngine couldn't start because of an error.")
    }
  }
  
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      microphoneButton.isEnabled = true
    } else {
      microphoneButton.isEnabled = false
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
    sections[section].expanded = !sections[section].expanded
    // Animate so that ingredients appear and disappear
    tableView.beginUpdates()
    for i in 0 ..< sections[section].ingredients.count {
      tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
    }
    tableView.endUpdates()
  }

 /* func removeSection(header: ExpandableHeaderView, section: Int) {
    removeSection(name: sections[section].category)
    save()
  }*/
  
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
