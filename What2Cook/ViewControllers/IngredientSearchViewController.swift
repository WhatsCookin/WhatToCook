//
//  IngredientSearchViewController.swift
//  What2Cook
//
//  Created by Hye Lim Joun on 4/10/18.
//  Copyright © 2018 hyelim. All rights reserved.
//

import UIKit
import Speech

class IngredientSearchViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, SFSpeechRecognizerDelegate {
  
  var fridgeViewController: FridgeViewController?
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  @IBOutlet weak var categoryTextField: UITextField!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var categoryDropDown: UIPickerView!
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var microphoneButton: UIButton!
  
  @IBAction func microphoneTapped(_ sender: AnyObject) {
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      microphoneButton.isEnabled = false
      microphoneButton.setTitle("Start Recording", for: .normal)
    } else {
      startRecording()
      microphoneButton.setTitle("Stop Recording", for: .normal)
    }
  }
  
  @IBAction func onAdd(_ sender: UIButton) {
    add(ingredient: textField.text!.capitalized)
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    let rowCount = fridgeViewController?.sections.count
    return rowCount!
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let rowTitle = fridgeViewController?.sections[row].category
    return rowTitle
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let chosenCategory = self.fridgeViewController?.sections[row].category
    if chosenCategory == "Unlisted" {
      self.categoryTextField.text = ""
    }
    else {
      self.categoryTextField.text = chosenCategory
    }
    self.categoryDropDown.isHidden = true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if(textField == self.textField) {
      self.textField.text = ""
    }
    else if(textField == categoryTextField) {
      self.categoryDropDown.isHidden = false
      dismissKeyboard()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
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
      
      if result != nil {
        var voiceCommand = result!.bestTranscription.formattedString
        //self.textView.text = voiceCommand
        print(voiceCommand)
        
        if voiceCommand == "Add" {
          voiceCommand = " add"
        }
        if (voiceCommand.range(of: " add ") != nil) {
          let addRange = voiceCommand.rangeEndIndex(toFind: " add ")
          voiceCommand = voiceCommand.substring(from: addRange)!
          if (voiceCommand.range(of: " to ") != nil) {
            let toStartRange = voiceCommand.rangeStartIndex(toFind: " to ")
            
            // Parse Ingredient
            var ingredient = voiceCommand.substring(to: toStartRange)!
            print(ingredient)
            self.textField.text = String(ingredient)
            
            // Parse Category
            let toEndRange = voiceCommand.rangeEndIndex(toFind: " to ")
            let category = voiceCommand.substring(from: toEndRange)!
            self.categoryTextField.text = String(category)
            self.add(ingredient: String(ingredient))
            voiceCommand = ""
          }
          else {
            print(voiceCommand)
            let ingredient = voiceCommand
            print(ingredient)
            self.textField.text = String(ingredient)
            self.add(ingredient: String(ingredient))
            voiceCommand = ""
          }
          
          print(voiceCommand)
          
          isFinal = (result?.isFinal)!
        }
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
    
    textView.text = "Say something, I'm listening!"
    
  }
  
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      microphoneButton.isEnabled = true
    } else {
      microphoneButton.isEnabled = false
    }
  }
  
  func add(ingredient: String) {
    // Correct capitalization
    //ingredient = ingredient.lowercased()
    
    let ingredientToAdd = ingredient
    // Check that the ingredient is not already in the fridge
    if !((fridgeViewController?.ingredientAlreadyAdded(ingredient: ingredientToAdd))!) {
      SpoonacularAPIManager().autocompleteIngredientSearch(ingredientToAdd) { (ingredients, error) in
        if ingredients!.count > 0 {
          
          self.textLabel.text = "Added " + self.textField.text!
          
          if self.categoryTextField.text != "" {
            let categoryToAddIn = self.categoryTextField.text
            self.fridgeViewController?.addIngredient(ingredient: ingredientToAdd, category: categoryToAddIn!)
          }
          else {
            self.fridgeViewController?.addIngredient(ingredient: ingredientToAdd)
          }
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    dismissKeyboard()
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
