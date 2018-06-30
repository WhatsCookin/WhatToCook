//
//  HomeViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
  
  @IBOutlet weak var sidebarButton: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  var recipes: [RecipeItem] = []
  var refreshControl: UIRefreshControl!
  
  var searchString: String?
  private var workItem: DispatchWorkItem?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    hideKeyboardWhenTappedAround()
    
    let user = PFUser.current()
    if user!["apiCalls"] == nil || user!["apiResults"] == nil || user!["homeResults"] == nil || user!["fridgeResults"] == nil {
      user!["apiCalls"] = 0
      user!["apiResults"] = 0
      user!["homeResults"] = 10
      user!["fridgeResults"] = 50
      user!.saveInBackground(block: { (success, error) in
        if (success) {
          print("The user data has been saved")
        } else {
          print("There was a problem with saving the user data")
        }
      })
    }
    
    searchString = "" //initial search parameter
    searchBar.delegate = self
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(HomeViewController.didPullToRefresh(_:)), for: .valueChanged)
    collectionView.insertSubview(refreshControl, at: 0)
    
    // Do any additional setup after loading the view.
    collectionView.dataSource = self
    collectionView.delegate = self
    
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = layout.minimumInteritemSpacing
    let cellsPerLine: CGFloat = 2
    let interItemSpacingTotal = layout.minimumLineSpacing * (cellsPerLine - 1)
    let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
    layout.itemSize = CGSize(width: width, height: width * 1)
    
    // Set side menu button
    if self.revealViewController() != nil {
      sidebarButton.target = self.revealViewController()
      sidebarButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    else {
      print("RevealVC was nil!!!")
    }
    
    // Load recipes to populate collection view after a 2 second delay to avoid extra API calls
    workItem = DispatchWorkItem {
      self.loadRecipes()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: workItem!)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    workItem?.cancel()
  }
  
  @objc func loadRecipes() {
    print("Calling loadRecipes()")
    
    SpoonacularAPIManager().getPopularRecipes(searchString!) { (recipes, error) in
      if let recipes = recipes {
        self.recipes = recipes
        //self.collectionView.reloadData()
        self.collectionView.isHidden = true;
        self.collectionView.reloadData()
        self.collectionView.performBatchUpdates(nil, completion: {
          (result) in
          self.collectionView.isHidden = false;
        })
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
    return cell
  }
  
  // Update based on the text in the search Bar
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchString = searchText.lowercased()
  }
  
  // Filter recipes by searchString
  @IBAction func beginSearch(_ sender: Any) {
    loadRecipes()
    self.searchBar.showsCancelButton = false
  }
  
  // Show cancel button on the Search Bar
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = true
  }
  
  // Clear the search Bar when canceling
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = false
    
    searchBar.text = ""
    searchString = ""
    
    searchBar.resignFirstResponder()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! UICollectionViewCell
    
    // Get the index path from the cell that was tapped
    if let indexPath = collectionView.indexPath(for: cell) {
      let recipe = recipes[indexPath.row]
      let singleViewController = segue.destination as! SingleViewController
      
      //Pass on the date to the DetailViewController
      singleViewController.recipe = recipe
      
      singleViewController.recipeList = recipes
      singleViewController.recipeIndex = indexPath.row
    }
  }
  
}

