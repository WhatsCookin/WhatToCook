//
//  SingleViewController.swift
//  What2Cook
//
//  Created by David Tan on 4/17/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class SingleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView! // tableView for ingredients in the recipe
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeTime: UILabel!
    
    var recipesList: [RecipeItem] = [] // change later to combine recipe and recipe item
    var ingredients: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        loadRecipes()
    }
    
    func loadRecipes() {
        SpoonacularAPIManager().getPopularRecipes() { (recipes, error) in
            if let recipes = recipes {
                self.recipesList = recipes
            } else if let error = error {
                print("Error getting recipes: " + error.localizedDescription)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientListCell")!
        //cell.textLabel?.text = sections[indexPath.section].ingredients[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
