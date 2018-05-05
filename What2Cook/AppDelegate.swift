//
//  AppDelegate.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

// Allows any view to hide keyboard when view is tapped
extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func displayError(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    // create an OK action
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
      // handle response here.
    }
    // add the OK action to the alert controller
    alertController.addAction(OKAction)
    present(alertController, animated: true) {
      // optional code for what happens after the alert controller has finished presenting
    }
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) in
      configuration.applicationId = "What2Cook"
      configuration.server = "http://what-2-cook.herokuapp.com/parse"
      configuration.clientKey = "h92hd3gf928fh898u8e9283rh829b9bc980f"
    }))
    
    if let currentUser = PFUser.current() {
      print("Welcome back \(currentUser.username!) 😀")
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let homeViewController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController")
      window?.rootViewController = homeViewController
    }
    
    NotificationCenter.default.addObserver(forName: Notification.Name("didLogout"), object: nil, queue: OperationQueue.main) { (Notification) in
      print("Logout notification received")
      self.logOut()
    }
    return true
  }

  func logOut() {
    // Logout the current user
    PFUser.logOutInBackground(block: { (error) in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("Successful loggout")
        // Load and show the login view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController")
        self.window?.rootViewController = loginViewController
      }
    })
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

