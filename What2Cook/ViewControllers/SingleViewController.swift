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

class SingleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate, SFSpeechRecognizerDelegate, OEEventsObserverDelegate {
  
  // Tableview for ingredients and directions in the recipe
  @IBOutlet weak var tableViewIngredients: UITableView!
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
  
  var openEarsEventsObserver = OEEventsObserver() // For OpenEars Speech Recognition
  
  var recipe: RecipeItem?
  var recipeList: [RecipeItem]?
  var recipeIndex: Int?
  
  var ingredients: [[String:Any]] = [[:]]
  var directions: [[String:Any]] = [[:]]
  
  var synthesizer = AVSpeechSynthesizer()
  var totalUtterance: Int = 0
  var toRead: [String] = []
  var currentStep = 0
  var utteranceRate = 0.45 as Float
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  private var lmPath, dicPath: String?
  
  @IBAction func onHelp(_ sender: UIButton) {
    displayError(title: "List of Voice Commands",
                 message: "Continue: Go to the next step\n" +
                          "Previous: Go to the previous step\n" +
                          "Repeat: Repeat the current step\n" +
                          "Step: Get the step number\n" +
                          "Slow Down: Slow down reading speed\n" +
                          "Speed up: Speed up reading speed\n" +
                          "Normal Speed: Reset reading speed\n\n" +
                          "Tap the microphone to get started!")
  }
  
  @IBAction func onBookmark(_ sender: UIButton) {
    let user = PFUser.current()
    if(sender.isSelected == false) {
      
      // Store object in array
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
      // Remove recipe from pfuser
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
    speechUtterance.rate = utteranceRate // 0.45 default speech rate
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
      currentStep = 0
      playMessage(message: "You're already at the first step.")
    }
  }
  
  func playCurrentStep() {
    synthesizer.stopSpeaking(at: .immediate)
    playMessage(message: toRead[currentStep])
  }
  
  @IBAction func microphoneTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    
    if !self.synthesizer.isSpeaking && toRead.count > 0{
      self.totalUtterance = toRead.count
      
      currentStep = -1
      nextStep()  // Play the first step in recipe instructions
    }
    
    if(sender.isSelected) {
      let lmGenerator = OELanguageModelGenerator()
      
      // Read dictionary text file and generate a language model using its words
      let path = Bundle.main.path(forResource: "Dictionary", ofType: "txt")
      do {
        let data = try String(contentsOfFile:path!, encoding: String.Encoding.utf8)
        let words = data.components(separatedBy: "\n")
        let name = "VoiceCommands"
        let err: Error! = lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        if(err != nil) {
          print("Error while creating initial language model: \(err)")
        } else {
          lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name)
          dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name)
          OELogging.startOpenEarsLogging()
          do {
            try OEPocketsphinxController.sharedInstance().setActive(true) // Setting the shared OEPocketsphinxController active is necessary before any of its properties are accessed.
          } catch {
            print("Error: it wasn't possible to set the shared instance to active: \"\(error)\"")
          }
          
          OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
        }
      }
      catch let error as NSError {
        print(error)
      }
    }
    else {
      stop()
      audioEngine.stop()
      OEPocketsphinxController.sharedInstance().stopListening()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.synthesizer.delegate = self
    self.openEarsEventsObserver.delegate = self
    
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
      cell.selectionStyle = .none
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
      cell.selectionStyle = .none
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
  
  /* Start of Apple Speech delegate methods */
  
  // Tells the delegate when the synthesizer has begun speaking an utterance.
  internal func speechSynthesizer(_: AVSpeechSynthesizer, didStart: AVSpeechUtterance) {
    // Prevent recipe instructions from being mistaken for voice commands
    OEPocketsphinxController.sharedInstance().suspendRecognition()
  }
  
  // Tells the delegate when the synthesizer has finished speaking an utterance.
  internal func speechSynthesizer(_: AVSpeechSynthesizer, didFinish: AVSpeechUtterance) {
    OEPocketsphinxController.sharedInstance().resumeRecognition()
  }
  
  /* Start of OpenEars delegate methods */
  
  func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
    
    // Actions for voice commands
    let voiceCommand = hypothesis!
    
    print("Local callback: The received hypothesis is \(voiceCommand) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
    
    if wordFound(in: voiceCommand, words: ["continue"]) {
      self.nextStep()
    }
    else if wordFound(in: voiceCommand, words: ["previous"]) {
      self.previousStep()
    }
    else if wordFound(in: voiceCommand, words: ["repeat"]) {
      self.playCurrentStep()
    }
    else if wordFound(in: voiceCommand, words: ["step"]) {
      self.playMessage(message: "We're on step " + String(self.currentStep + 1) + " out of " + String(self.toRead.count))
    }
    else if wordFound(in: voiceCommand, words: ["slow", "slow down"]) {
      self.changeSpeed(rate: self.utteranceRate * 0.8)
      self.playCurrentStep()
    }
    else if wordFound(in: voiceCommand, words: ["speed", "speed up"]) {
      self.changeSpeed(rate: self.utteranceRate * 1.2)
      self.playCurrentStep()
    }
    else if wordFound(in: voiceCommand, words: ["normal", "normal speed"]) {
      self.changeSpeed(rate: 0.45)
      self.playCurrentStep()
    }
  }
  
  // Returns true if the voice command contains one of the words
  func wordFound(in voiceCommand: String, words: [String]) -> Bool {
    var found = false
    for word in words {
      if (voiceCommand.range(of: word) != nil) {
        found = true
      }
    }
    return found
  }
  
  // An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
  // This might be useful in debugging a conflict between another sound class and Pocketsphinx.
  func pocketsphinxRecognitionLoopDidStart() {
    print("Local callback: Pocketsphinx started.") // Log it.
  }
  
  // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
  func pocketsphinxDidStartListening() {
    print("Local callback: Pocketsphinx is now listening.") // Log it.
  }
  
  // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
  func pocketsphinxDidDetectSpeech() {
    print("Local callback: Pocketsphinx has detected speech.") // Log it.
  }
  
  // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
  func pocketsphinxDidDetectFinishedSpeech() {
    print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.") // Log it.
    print()
  }
  
  // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
  // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
  func pocketsphinxDidStopListening() {
    print("Local callback: Pocketsphinx has stopped listening.") // Log it.
  }
  
  // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
  // Going to react to speech until listening is resumed.  This can happen as a result of Flite speech being
  // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
  // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
  func pocketsphinxDidSuspendRecognition() {
    print("Local callback: Pocketsphinx has suspended recognition.") // Log it.
  }
  
  // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
  // having been suspended it is now resuming.  This can happen as a result of Flite speech completing
  // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
  // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
  func pocketsphinxDidResumeRecognition() {
    print("Local callback: Pocketsphinx has resumed recognition.") // Log it.
  }
  
  // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
  // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
  func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
    
    print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
  }
  
  // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
  // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
  func fliteDidStartSpeaking() {
    print("Local callback: Flite has started speaking") // Log it.
  }
  
  // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
  // complex interaction between sound classes.
  func fliteDidFinishSpeaking() {
    print("Local callback: Flite has finished speaking") // Log it.
  }
  
  func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
    print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.") // Log it.
  }
  
  func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on OELogging.startOpenEarsLogging() to learn why.
    print("Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)") // Log it.
  }
  
  /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
  func pocketsphinxFailedNoMicPermissions() {
    print("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
  }
  
  /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result  (will only be returned on iOS7 or later).*/
  
  func micPermissionCheckCompleted(withResult: Bool) {
    print("Local callback: mic check completed.")
  }
}
