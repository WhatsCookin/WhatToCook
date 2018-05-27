//
//  SingleViewController.swift
//  What2Cook
//
//  Created by David Tan on 4/17/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import Parse

class SingleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate {
  
  @IBOutlet weak var tableViewIngredients: UITableView! // tableView for ingredients in the recipe
  // tableview for directions in the recipe
  @IBOutlet weak var tableViewDirections: UITableView! {
    didSet {
      tableViewDirections.rowHeight = UITableViewAutomaticDimension
      tableViewDirections.estimatedRowHeight = 50
    }
  }
  
  @IBOutlet weak var recipeImage: UIImageView!
  @IBOutlet weak var recipeName: UILabel!
  @IBOutlet weak var recipeTime: UILabel!
  @IBOutlet weak var recipeLikes: UILabel!
  @IBOutlet weak var recipeServings: UILabel!
  @IBOutlet weak var microphoneButton: UIButton!
  @IBOutlet weak var bookmarksButton: UIButton!
  
  var recipe: RecipeItem?
  var recipeList: [RecipeItem]?
  var recipeIndex: Int?
  
  var ingredients: [[String:Any]] = [[:]]
  var directions: [[String:Any]] = [[:]]
  
  var synthesizer = AVSpeechSynthesizer()
  var totalUtterance: Int = 0
  var toRead: [String] = []
  var currentStep = 0
  var ignoredChars = 0
  var utteranceRate = 0.45 as Float
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  @IBAction func onBookmark(_ sender: UIButton) {
    let user = PFUser.current()
    if(sender.isSelected == false) {
      // store object in array
      recipe?.bookmarked = true
      if(user!["bookmarks"] == nil) {   // Create new bookmarks array
        let bookmarks = NSMutableArray.init()
        bookmarks.add(recipe?.toDictionary() as Any)
        user!["bookmarks"] = bookmarks
      }
      else {
        // Edit existing bookmarks array
        let bookmarks = user!["bookmarks"] as! NSMutableArray
        bookmarks.add(recipe?.toDictionary() as Any)
        user!["bookmarks"] = bookmarks
      }
    }
    else {
      // remove recipe from pfuser
      recipe?.bookmarked = false
      let bookmarks = user!["bookmarks"] as! NSMutableArray
      for bookmark in bookmarks {
        let recipe = RecipeItem(dictionary: bookmark as! [String : Any])
        if(recipe.id == self.recipe?.id) {
          bookmarks.remove(bookmark)
          print("recipe removed successfully")
        }
      }
      user!["bookmarks"] = bookmarks
    }
    bookmarksButton.isSelected = (recipe?.bookmarked)!
    user!.saveInBackground(block: { (success, error) in
      if (success) {
        print("The user data has been saved")
      } else {
        print("There was a problem with saving the user data")
      }
    })
  }
  
  func playMessage(message: String) {
    synthesizer.stopSpeaking(at: .immediate)
    let speechUtterance = AVSpeechUtterance(string: message)
    let voice = AVSpeechSynthesisVoice(language: "en-EN")
    speechUtterance.voice = voice
    speechUtterance.rate = utteranceRate // 0.5 default speech rate
    _ = AVSpeechSynthesisVoice.speechVoices()
    self.synthesizer.speak(speechUtterance)
  }
  
  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
  }
  
  func start() {
    synthesizer.continueSpeaking()
  }
  
  func changeSpeed(rate: Float) {
    utteranceRate = rate
  }
  
  func nextStep() {
    synthesizer.stopSpeaking(at: .immediate)
    if(currentStep + 1 < toRead.count) {
      currentStep = currentStep + 1
      playMessage(message: "Step " + String(currentStep + 1) + ". " + toRead[currentStep])
    }
    else {
      currentStep = toRead.count
      playMessage(message: "End of recipe.")
    }
  }
  
  func previousStep() {
    synthesizer.stopSpeaking(at: .immediate)
    if(currentStep > 0) {
      currentStep = currentStep - 1
      playMessage(message: "Step " + String(currentStep + 1) + ". " + toRead[currentStep])
    }
    else {
      synthesizer.stopSpeaking(at: .immediate)
      currentStep = -1
      playMessage(message: "You're already at the first step.")
    }
  }
  
  func playCurrentStep() {
    synthesizer.stopSpeaking(at: .immediate)
    playMessage(message: toRead[currentStep])
  }
  
  @IBAction func microphoneTapped(_ sender: UIButton) {
    print("tap")
    sender.isSelected = !sender.isSelected
    
    if !self.synthesizer.isSpeaking && toRead.count > 0{
      self.totalUtterance = toRead.count
      
      currentStep = -1
      nextStep()  // Play the first step in recipe instructions
    }
    
    if audioEngine.isRunning {
      stop()
      audioEngine.stop()
      recognitionRequest?.endAudio()
      let audioSession = AVAudioSession.sharedInstance()
      do {
        try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try audioSession.setMode(AVAudioSessionModeDefault)
        
      } catch {
        print("audioSession properties weren't set because of an error.")
      }
      
      microphoneButton.isEnabled = false
    } else {
      startRecording()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    if let recipe = recipe {
      bookmarksButton.isSelected = recipe.bookmarked
      
      recipeName.text = recipe.name
      recipeTime.text = String(recipe.time) + " min"
      recipeLikes.text = String(recipe.likes) + " likes"
      recipeServings.text = String(recipe.servings)
      
      let url = URL(string: recipe.image)
      recipeImage.af_setImage(withURL: url!)
      
      ingredients = recipe.ingredients
      directions = recipe.directions
    }
    
    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(sender:)))
    swipeLeft.direction = .left
    self.view.addGestureRecognizer(swipeLeft)
    
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(sender:)))
    swipeRight.direction = .right
    self.view.addGestureRecognizer(swipeRight)
    
    tableViewIngredients.delegate = self
    tableViewIngredients.dataSource = self
    tableViewIngredients.rowHeight = UITableViewAutomaticDimension
    tableViewIngredients.estimatedRowHeight = 50
    
    tableViewDirections.delegate = self
    tableViewDirections.dataSource = self
    tableViewDirections.rowHeight = UITableViewAutomaticDimension
    tableViewDirections.estimatedRowHeight = 100
    
    microphoneButton.isEnabled = false
    
    speechRecognizer?.delegate = self
    
    SFSpeechRecognizer.requestAuthorization { (authStatus) in
      
      var isButtonEnabled = false
      
      switch authStatus {
      case .authorized:
        isButtonEnabled = true
        
      case .denied:
        isButtonEnabled = false
        print("User denied access to speech recognition")
        
      case .restricted:
        isButtonEnabled = false
        print("Speech recognition restricted on this device")
        
      case .notDetermined:
        isButtonEnabled = false
        print("Speech recognition not yet authorized")
      }
      
      OperationQueue.main.addOperation() {
        self.microphoneButton.isEnabled = isButtonEnabled
      }
    }
  }
  
  @objc func didSwipe(sender: UISwipeGestureRecognizer) {
    switch sender.direction {
    case UISwipeGestureRecognizerDirection.left:
      print("swipe left")
      if (recipeIndex! + 1 < recipeList!.count) {
        recipeIndex = recipeIndex! + 1
        recipe = recipeList?[recipeIndex!]
        viewDidLoad()
        tableViewIngredients.reloadData()
        tableViewDirections.reloadData()
      }
    case UISwipeGestureRecognizerDirection.right:
      print("swipe right")
      if (recipeIndex! - 1 > -1) {
        recipeIndex = recipeIndex! - 1
        recipe = recipeList?[recipeIndex!]
        viewDidLoad()
        tableViewIngredients.reloadData()
        tableViewDirections.reloadData()
      }
    default:
      break
    }
  }
  
  func startRecording() {
    if recognitionTask != nil {  //1
      recognitionTask?.cancel()
      recognitionTask = nil
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
    } catch {
      print("audioSession properties weren't set because of an error.")
    }
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    let inputNode = audioEngine.inputNode
    
    guard let recognitionRequest = recognitionRequest else {
      fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
    }
    
    recognitionRequest.shouldReportPartialResults = true
    
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
      
      var isFinal = false
      
      // Start parsing voice command
      if result != nil {
        var voiceCommand = result!.bestTranscription.formattedString.lowercased().substring(from: self.ignoredChars) ?? ""
        print("string: " + result!.bestTranscription.formattedString)

        // Fix common listening mistakes
        voiceCommand = voiceCommand.replacingOccurrences(of: "what's that", with: "what step")
        voiceCommand = voiceCommand.replacingOccurrences(of: "skit", with: "skip")
        voiceCommand = voiceCommand.replacingOccurrences(of: "scape", with: "skip")
        voiceCommand = voiceCommand.replacingOccurrences(of: "lower", with: "slower")
        voiceCommand = voiceCommand.replacingOccurrences(of: "sslower", with: "slower")
        
        print(voiceCommand)
        
        if voiceCommand.range(of: "next") != nil || voiceCommand.range(of: "skip") != nil {
          self.nextStep()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "go back") != nil || voiceCommand.range(of: "what was the last step") != nil {
          self.previousStep()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "repeat that") != nil || voiceCommand.range(of: "what was that") != nil || voiceCommand.range(of: "again") != nil {
          self.playCurrentStep()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "what step") != nil {
          self.playMessage(message: "We're on step " + String(self.currentStep + 1) + " out of " + String(self.toRead.count))
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "pause") != nil || voiceCommand.range(of: "stop") != nil {
          self.stop()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "continue") != nil {
          self.start()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "slow down") != nil {
          self.changeSpeed(rate: self.utteranceRate * 0.8)
          self.playCurrentStep()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        else if voiceCommand.range(of: "speed up") != nil {
          self.changeSpeed(rate: self.utteranceRate * 1.2)
          self.playCurrentStep()
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
        /*else if voiceCommand.range(of: "play all") != nil {
         for _ in 0..<self.toRead.count {
         self.nextStep()
         self.ignoredChars = result!.bestTranscription.formattedString.count
         }
         }*/
        /*else if voiceCommand.range(of: "go to step") != nil {
          let range = voiceCommand.rangeEndIndex(toFind: " go to step ")
          voiceCommand = voiceCommand.substring(from: range)!
          
          print("full command: " + voiceCommand)
          let stringNumber = voiceCommand
          print("string number: " + stringNumber)

          let numberFormatter:NumberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.spellOut
            let number = numberFormatter.number(from: stringNumber)
          print("number: " + String(Int(truncating: number!) - 1))
            
          self.currentStep = Int(truncating: number!) - 1
          print("new step: " + String(self.currentStep))
            self.nextStep()
            self.ignoredChars = result!.bestTranscription.formattedString.count
        }*/
        
        print(voiceCommand)
        
        isFinal = (result?.isFinal)!
      }
      
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.microphoneButton.isEnabled = true
      }
    })
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("audioEngine couldn't start because of an error.")
    }
  }
  
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      microphoneButton.isEnabled = true
    } else {
      microphoneButton.isEnabled = false
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count: Int?
    if tableView == self.tableViewIngredients {
      count = ingredients.count
    }
    else {
      count = directions.count
    }
    return count!
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == self.tableViewIngredients {
      let cell = tableViewIngredients.dequeueReusableCell(withIdentifier: "IngredientListCell", for: indexPath) as! IngredientListCell
      
      cell.ingredient = ingredients[indexPath.row]
        
      if indexPath.row % 2 == 0 {
        cell.backgroundColor = UIColor.white
      }
      else {
        cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
      }
        
      return cell
    }
    else {
      let cell = tableViewDirections.dequeueReusableCell(withIdentifier: "DirectionListCell", for: indexPath) as! DirectionListCell
      cell.direction = directions[indexPath.row]
      if(directions[indexPath.row]["step"] != nil) {
        toRead.append(directions[indexPath.row]["step"] as! String)
      }
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
        }
        else {
            cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        }
        
      return cell
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {
    recipeImage.gradient(colors: [UIColor.clear.cgColor, UIColor.black.cgColor],opacity: 1, location: [0.70,1])
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


