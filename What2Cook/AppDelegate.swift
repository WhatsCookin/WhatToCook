//
//  AppDelegate.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/1/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Parse

extension String {
  var length: Int {
    get {
      return self.characters.count
    }
  }
  
  func substring(to : Int) -> String? {
    if (to >= length) {
      return nil
    }
    let toIndex = self.index(self.startIndex, offsetBy: to)
    return self.substring(to: toIndex)
  }
  
  func substring(from : Int) -> String? {
    if (from >= length) {
      return nil
    }
    let fromIndex = self.index(self.startIndex, offsetBy: from)
    return self.substring(from: fromIndex)
  }
  
  func substring(_ r: Range<Int>) -> String {
    let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
    let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
    return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
  }
  
  func character(_ at: Int) -> Character {
    return self[self.index(self.startIndex, offsetBy: at)]
  }
  
  func rangeStartIndex(toFind: String) -> Int {
    if let range = self.range(of: toFind) {
      let startPos = self.distance(from: self.startIndex, to: range.lowerBound)
      return startPos
    }
    return -1
  }
  
  func rangeEndIndex(toFind: String) -> Int {
    if let range = self.range(of: toFind) {
      let endPos = self.distance(from: self.startIndex, to: range.upperBound)
      return endPos
    }
    return -1
  }
}

extension UIColor {
  var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    if getRed(&r, green: &g, blue: &b, alpha: &a) {
      return (r,g,b,a)
    }
    return (0,0,0,0)
  }
  // hue, saturation, brightness and alpha components from UIColor**
  var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
    var hue:CGFloat = 0
    var saturation:CGFloat = 0
    var brightness:CGFloat = 0
    var alpha:CGFloat = 0
    if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
      return (hue,saturation,brightness,alpha)
    }
    return (0,0,0,0)
  }
  var htmlRGBColor:String {
    return String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255))
  }
  var htmlRGBaColor:String {
    return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
  }
  
  public convenience init?(hexString: String) {
    let r, g, b, a: CGFloat
    
    if hexString.hasPrefix("#") {
      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      let hexColor = hexString.substring(from: start)
      
      if hexColor.characters.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          a = CGFloat(hexNumber & 0x000000ff) / 255
          
          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }
    
    return nil
  }
}

extension UIViewController {
  // Allows any view to hide keyboard when view is tapped
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
      configuration.clientKey = Constants().clientKey
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

