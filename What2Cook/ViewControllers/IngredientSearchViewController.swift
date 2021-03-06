//
//  IngredientSearchViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Speech

class IngredientSearchViewController: UIViewController, UITextFieldDelegate, SFSpeechRecognizerDelegate {
  
  var fridgeViewController: FridgeViewController?
  var category: String!
  private var ignoredChars = 0  // For continuous speech recognition
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  @IBOutlet weak var micInstructionsLabel: UILabel!
  @IBOutlet weak var instructionsLabel: UILabel!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textLabel: UILabel!
  
  @IBOutlet weak var microphoneButton: UIButton!
  
  @IBAction func microphoneTapped(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      microphoneButton.isEnabled = false
      micInstructionsLabel.isHidden = true
    } else {
      startRecording()
      micInstructionsLabel.isHidden = false
    }
  }
  
  @IBAction func onBack(_ sender: UIButton) {
    self.view.removeFromSuperview()
  }
  
  @IBAction func onAdd(_ sender: UIButton) {
    let ingredientToAdd = textField.text!.capitalized
    // Check that the ingredient is not already in the fridge
    if !((fridgeViewController?.ingredientAlreadyAdded(ingredient: ingredientToAdd))!) {
      SpoonacularAPIManager().autocompleteIngredientSearch(ingredientToAdd) { (ingredients) in
        if ingredients!.count > 0 {
          self.fridgeViewController?.addIngredient(ingredient: ingredientToAdd, category: self.category)
          self.textLabel.text = "Added " + self.textField.text! + "!"
        }
        else {
          self.displayError(title: "Cannot Add Ingredient", message: "Ingredient not found.")
        }
      }
    }
    else {
      displayError(title: "Cannot Add Ingredient", message: "You already have that ingredient.")
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.textField.text = ""
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textField.delegate = self
    micInstructionsLabel.isHidden = true
    instructionsLabel.text = "Enter Ingredient to Add to " + category + ":"
    
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    self.textField.delegate = self
    self.hideKeyboardWhenTappedAround()
    
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
  
  func startRecording() {
    if recognitionTask != nil {
      recognitionTask?.cancel()
      recognitionTask = nil
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryRecord)
      try audioSession.setMode(AVAudioSessionModeMeasurement)
      try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
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
        var voiceCommand = result!.bestTranscription.formattedString.substring(from: self.ignoredChars) ?? ""
        
        // Correct common mistakes
        voiceCommand = voiceCommand.replacingOccurrences(of: "Add ", with: " add ")
        voiceCommand = voiceCommand.replacingOccurrences(of: "At ", with: " add ")
        voiceCommand = voiceCommand.replacingOccurrences(of: " at ", with: " add ")
        voiceCommand = voiceCommand.replacingOccurrences(of: "To ", with: " to ")
        voiceCommand = voiceCommand.replacingOccurrences(of: "Two ", with: " to ")
        voiceCommand = voiceCommand.replacingOccurrences(of: " two ", with: " to ")
        
        if (voiceCommand.range(of: " add ", options:NSString.CompareOptions.backwards) != nil) {
          // Parse Ingredient
          self.textField.text = ""
          
          let addRange = voiceCommand.rangeEndIndex(toFind: " add ")
          voiceCommand = voiceCommand.substring(from: addRange)!
          
          let ingredient = voiceCommand.capitalized
          
          self.textField.text = String(ingredient)
          self.ignoredChars = result!.bestTranscription.formattedString.count
        }
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    dismissKeyboard()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let maxLength = 20
    let currentString: NSString = textField.text! as NSString
    let newString: NSString =
      currentString.replacingCharacters(in: range, with: string) as NSString
    return newString.length <= maxLength
  }
}
