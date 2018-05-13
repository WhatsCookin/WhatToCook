//
//  HomeViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet weak var sidebarButton: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var recipes: [RecipeItem] = []
  var refreshControl: UIRefreshControl!
    
  var gradient: CAGradientLayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(HomeViewController.didPullToRefresh(_:)), for: .valueChanged)
    collectionView.insertSubview(refreshControl, at: 0)
    
    // Do any additional setup after loading the view.
    collectionView.dataSource = self
    collectionView.delegate = self
    
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.minimumInteritemSpacing = 5
    layout.minimumLineSpacing = layout.minimumInteritemSpacing
    let cellsPerLine: CGFloat = 2
    let interItemSpacingTotal = layout.minimumLineSpacing * (cellsPerLine - 1)
    let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
    layout.itemSize = CGSize(width: width, height: width * 3 / 2)
    
    // Set side menu button
    if self.revealViewController() != nil {
        sidebarButton.target = self.revealViewController()
        sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    else {
        print("RevealVC was nil!!!")
    }
    // Load recipes to populate collection view
    loadRecipes()
  }
    
    func loadRecipes() {
        print("Calling loadRecipes()")
      // Commented out to avoid exceeding API call limit
        SpoonacularAPIManager().getPopularRecipes() { (recipes, error) in
            if let recipes = recipes {
                self.recipes = recipes
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
                
            } else if let error = error {
                print("Error getting recipes: " + error.localizedDescription)
            }
        }
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
    loadRecipes()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return recipes.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
    cell.recipe = recipes[indexPath.item] as RecipeItem
    
    /*let imageView: UIImageView = cell.recipeImage
    
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = (imageView.frame)
    gradient.colors = [UIColor.clear, UIColor.black]
    gradient.locations = [0.9,1]
    //imageView.layer.insertSublayer(gradient, at: 0)
    imageView.layer.mask = gradient
    
    cell.recipeImage = imageView*/
    
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! UICollectionViewCell
    
    // Get the index path from the cell that was tapped
    if let indexPath = collectionView.indexPath(for: cell) {
      let recipe = recipes[indexPath.row]
      let singleViewController = segue.destination as! SingleViewController
      
      //Pass on the date to the DetailViewController
      singleViewController.recipe = recipe
    }
  }
    
}

