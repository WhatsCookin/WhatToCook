//
//  DataManager.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 5/19/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import Foundation
import Parse

class DataManager {
  static var dictionary = [String: Any]()
  
  static func add(key: String, value: Any) {
    DataManager.dictionary[key] = value
  }
  
  static func saveUserData() {
    let user = User(dictionary: DataManager.dictionary)
    print(user.name)
  }
}
