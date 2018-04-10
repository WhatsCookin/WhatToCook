//
//  Recipe.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation

class Recipe {
  var image_url: String?  // URL of the image
  var source_url: String? // Original Url of the recipe on the publisher's site
  var f2f_url: String?  // Url of the recipe on Food2Fork.com
  var title: String?  // Title of the recipe
  var publisher: String?  // Name of the Publisher
  var publisher_url: String?  // Base url of the publisher
  var social_rank: String?  // The Social Ranking of the Recipe (As determined by our Ranking Algorithm)
  var page: String? // The page number that is being returned (To keep track of concurrent requests)

  init(dictionary: [String: Any]) {
    image_url = dictionary["image_url"] as? String
    source_url = dictionary["source_url"] as? String
    f2f_url = dictionary["f2f_url"] as? String
    title = dictionary["title"] as? String
    publisher = dictionary["publisher"] as? String
    publisher_url = dictionary["publisher_url"] as? String
    social_rank = dictionary["social_rank"] as? String
    page = dictionary["page"] as? String
  }
  
  static func recipes(with array: [[String: Any]]) -> [Recipe] {
    return array.flatMap({ (dictionary) -> Recipe in
      Recipe(dictionary: dictionary)
    })
  }
}

