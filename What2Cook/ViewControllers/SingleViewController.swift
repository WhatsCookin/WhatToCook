//
//  SingleViewController.swift
//  What2Cook
//
//  Created by David Tan on 4/17/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import AVFoundation

class SingleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate {

    @IBOutlet weak var tableViewIngredients: UITableView! // tableView for ingredients in the recipe
    @IBOutlet weak var tableViewDirections: UITableView! // tableview for directions in the recipe
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeTime: UILabel!
    @IBOutlet weak var recipeLikes: UILabel!
    @IBOutlet weak var recipeServings: UILabel!
    
    var recipe: RecipeItem?
    var recipeList: [RecipeItem]?
    var recipeIndex: Int?
    
    var ingredients: [[String:Any]] = [[:]]
    var directions: [[String:Any]] = [[:]]
    
    var synthesizer = AVSpeechSynthesizer()
    var totalUtterance: Int = 0
    var toRead: [String] = []
    var currentStep = 0
  
  @IBAction func play(_ sender: Any) {
    if !self.synthesizer.isSpeaking && toRead.count > 0{
      self.totalUtterance = toRead.count
      
      currentStep = -1
      nextStep()  // Play the first step in recipe instructions
    }
  }
  
  @IBAction func onNext(_ sender: UIButton) {
    nextStep()
  }
  @IBAction func onPrev(_ sender: UIButton) {
    previousStep()
  }
  
  func playMessage(message: String) {
    let speechUtterance = AVSpeechUtterance(string: message)
    let voice = AVSpeechSynthesisVoice(language: "en-EN")
    speechUtterance.voice = voice
    speechUtterance.rate = 0.45 // 0.5 default speech rate
    _ = AVSpeechSynthesisVoice.speechVoices()
    self.synthesizer.speak(speechUtterance)
  }
  
  func nextStep() {
    if(currentStep + 1 < toRead.count) {
      currentStep = currentStep + 1
      playMessage(message: toRead[currentStep])
    }
    else {
      playMessage(message: "End of recipe.")
    }
  }
  
  func previousStep() {
    if(currentStep > 0) {
      currentStep = currentStep - 1
      playMessage(message: toRead[currentStep])
    }
    else {
      playMessage(message: "You're already at the first step.")
    }
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let recipe = recipe {
            recipeName.text = recipe.name
            recipeTime.text = String(recipe.time) + " min"
            recipeLikes.text = String(recipe.likes) + " likes"
            recipeServings.text = String(recipe.servings)
            
            let url = URL(string: recipe.image)
            recipeImage.af_setImage(withURL: url!)
            
            ingredients = recipe.ingredients
            directions = recipe.directions
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(sender:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(sender:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        tableViewIngredients.delegate = self
        tableViewIngredients.dataSource = self
        tableViewIngredients.rowHeight = UITableViewAutomaticDimension
        tableViewIngredients.estimatedRowHeight = 50
        
        tableViewDirections.delegate = self
        tableViewDirections.dataSource = self
        tableViewDirections.rowHeight = UITableViewAutomaticDimension
        tableViewDirections.estimatedRowHeight = 100
        
    }
    
    @objc func didSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.left:
            print("swipe left")
            if (recipeIndex! + 1 < recipeList!.count) {
                recipeIndex = recipeIndex! + 1
                recipe = recipeList?[recipeIndex!]
                viewDidLoad()
                tableViewIngredients.reloadData()
                tableViewDirections.reloadData()
            }
        case UISwipeGestureRecognizerDirection.right:
            print("swipe right")
            if (recipeIndex! - 1 > -1) {
                recipeIndex = recipeIndex! - 1
                recipe = recipeList?[recipeIndex!]
                viewDidLoad()
                tableViewIngredients.reloadData()
                tableViewDirections.reloadData()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count: Int?
        if tableView == self.tableViewIngredients {
            count = ingredients.count
        }
        else {
            count = directions.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewIngredients {
            let cell = tableViewIngredients.dequeueReusableCell(withIdentifier: "IngredientListCell", for: indexPath) as! IngredientListCell
            
            cell.ingredient = ingredients[indexPath.row]
            return cell
        }
        else {
            let cell = tableViewDirections.dequeueReusableCell(withIdentifier: "DirectionListCell", for: indexPath) as! DirectionListCell
            cell.direction = directions[indexPath.row]
            toRead.append(directions[indexPath.row]["step"] as! String)
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        recipeImage.gradient(colors: [UIColor.clear.cgColor, UIColor.black.cgColor],opacity: 1, location: [0.70,1])
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


