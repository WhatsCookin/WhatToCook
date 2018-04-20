//
//  Ingredient.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/13/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class Ingredient {
  var name: String!
  var image: String!
  
  init(dictionary: [String: Any]) {
    name = dictionary["name"] as? String
    image = dictionary["image"] as? String
    print(name)
  }
}
