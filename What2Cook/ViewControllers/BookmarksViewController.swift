//
//  BookmarksViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/23/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class BookmarksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  //@IBOutlet weak var sidebarButton: UIBarButtonItem!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var recipes: [RecipeItem] = []
  var refreshControl: UIRefreshControl!
  
  
    @IBAction func goBack(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SWRevealViewController") as? UIViewController {
            present(vc, animated: true, completion: nil)
        }
    }
    
  func clearData() {
    let user = PFUser.current()
    user!["bookmarks"] = []
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
  }
  
  func loadBookmarks() {
    recipes = []
    let user = PFUser.current()
    let bookmarks = user?.object(forKey: "bookmarks") as? [Dictionary<String, AnyObject>]
    
    if bookmarks != nil {
      for bookmark in bookmarks! {
        let recipe = RecipeItem(dictionary: bookmark)
        print(recipe.name)
        recipes.append(recipe)
      }
    }
    collectionView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("viewWillAppear")
    loadBookmarks()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadBookmarks()
    
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
  
  // removing spacing
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
    
    if segue.identifier == "detailSegue" {
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
}



