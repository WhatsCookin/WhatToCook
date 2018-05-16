//
//  SingleViewController.swift
//  What2Cook
//
//  Created by David Tan on 4/17/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class SingleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewIngredients: UITableView! // tableView for ingredients in the recipe
    @IBOutlet weak var tableViewDirections: UITableView! // tableview for directions in the recipe
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeTime: UILabel!
    @IBOutlet weak var recipeLikes: UILabel!
    @IBOutlet weak var recipeServings: UILabel!
    
    var recipe: RecipeItem?
    
    var ingredients: [[String:Any]] = [[:]]
    var directions: [[String:Any]] = [[:]]
    
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
        
        tableViewIngredients.delegate = self
        tableViewIngredients.dataSource = self
        tableViewIngredients.rowHeight = UITableViewAutomaticDimension
        tableViewIngredients.estimatedRowHeight = 50
        
        tableViewDirections.delegate = self
        tableViewDirections.dataSource = self
        tableViewDirections.rowHeight = UITableViewAutomaticDimension
        tableViewDirections.estimatedRowHeight = 80
        
        //recipeImage.gradientSingle(colors: [UIColor.clear.cgColor, UIColor.black.cgColor],opacity: 1, location: [0.70,1])
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


