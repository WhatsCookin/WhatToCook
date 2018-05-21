//
//  User.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/16/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

class User: PFObject, PFSubclassing {
  static func parseClassName() -> String {
    return "User"
  }
  
  var dictionary: [String: Any]?
  private static var _current: User?
  
  var name: String
  var recipes: [RecipeItem]?
  var friends: [User]?
  var sections: [Section]?  // Ingredients in fridge
  var favorited: [RecipeItem]?
  
  init(dictionary: [String: Any]) {
    self.dictionary = dictionary
    
    name = dictionary["name"] as! String
    recipes = dictionary["recipes"] as? [RecipeItem]
    friends = dictionary["friends"] as? [User]
    sections = dictionary["sections"] as? [Section]
    favorited = dictionary["favorited"] as? [RecipeItem]
    
    super.init()
  }
  
  static var current: User? {
    get {
      if _current == nil {
        let defaults = UserDefaults.standard
        if let userData = defaults.data(forKey: "currentUserData") {
          let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any]
          _current = User(dictionary: dictionary)
        }
      }
      return _current
    }
    set (user) {
      _current = user
      let defaults = UserDefaults.standard
      if let user = user {
        let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
        defaults.set(data, forKey: "currentUserData")
      } else {
        defaults.removeObject(forKey: "currentUserData")
      }
    }
  }
}
