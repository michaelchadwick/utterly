//
//  ViewController.swift
//  Utterly
//
//  Created by Michael Chadwick on 11/25/16.
//  Copyright © 2016 Michael Chadwick. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, NSSpeechSynthesizerDelegate, NSWindowDelegate {

  let mainWindow = NSApplication.shared().windows.first

  // MARK - Flags
  var isDebug = true
  var isPaused = false

  // MARK - Synth
  let synth = NSSpeechSynthesizer()

  // MARK - Setup Actions
  func setupInitialText() {
    textToUtter.string = INITIAL_TEXT
  }
  func setupButtonIcons() {
    buttonPlayStop.title = ICON_PLAY
    buttonPauseResume.title = ICON_PAUSE
    buttonPauseResume.isEnabled = false
  }
  func populateVoices() {
    let voiceNames = NSSpeechSynthesizer.availableVoices()
    popupVoices.removeAllItems()
    for voiceFullName in voiceNames
    {
      var voiceBaseName = strToArr(str: voiceFullName)
      popupVoices.addItem(withTitle: voiceBaseName[voiceBaseName.count-1])
    }
    popupVoices.selectItem(at: 0)
  }
  func setSynthVoice() {
    synth.setVoice(APPLE_VOICE_PREFIX + (popupVoices.selectedItem?.title)!)
  }
  func setSynthSpeed() {
    synth.rate = opsSpeedSlider.floatValue
  }
  func setSynthPitch() throws {
    let newPitch = opsPitchSlider.floatValue
    try self.synth.setObject(newPitch, forProperty: NSSpeechPitchBaseProperty)
  }
  func setSynthPitchMod() throws {
    let newPitchMod = opsPitchModSlider.floatValue
    try self.synth.setObject(newPitchMod, forProperty: NSSpeechPitchModProperty)
  }
  func setSynthVolume() {
    let newVolume = opsVolumeSlider.floatValue/100
    synth.volume = newVolume
  }
  func setupOptions() {
    opsSpeedText.stringValue = opsSpeedSlider.stringValue
    opsPitchText.stringValue = opsPitchSlider.stringValue
    opsPitchModText.stringValue = opsPitchModSlider.stringValue
    opsVolumeText.stringValue = opsVolumeSlider.stringValue
  }

  // MARK - Utterance Methods
  func startStopUtterance() {
    if (synth.isSpeaking) {
      stopUtterance()
    } else {
      startUtterance()
    }
  }
  func startUtterance() {
    let utterance = (textToUtter.textStorage?.string)!

    // make sure we stop any current speaking
    synth.stopSpeaking()

    // set up attributes
    setSynthVoice()
    setSynthSpeed()
    do {
      try setSynthPitch()
    } catch {
      debugLog(msg: "Could not set synth pitch")
    }
    do {
      try setSynthPitchMod()
    } catch {
      debugLog(msg: "Could not set synth pitch mod")
    }
    setSynthVolume()

    // speak!
    buttonPlayStop.title = ICON_STOP
    buttonPauseResume.isEnabled = true
    synth.startSpeaking(utterance)

    logSpeechStats()

    // save to file, if enabled
    if (opsSaveToFile.state == NSOnState) {
      saveUtteranceToFile()
    }
  }
  func stopUtterance() {
    synth.stopSpeaking()
    buttonPlayStop.title = ICON_PLAY
    buttonPauseResume.isEnabled = false
  }
  func pauseResumeUtterance() {
    if (isPaused) {
      resumeUtterance()
    } else {
      pauseUtterance()
    }
  }
  func pauseUtterance() {
    debugLog(msg: "|| utterance PAUSED")
    synth.pauseSpeaking(at: NSSpeechBoundary(rawValue: 0)!)
    buttonPauseResume.title = ICON_RESUME
    buttonPlayStop.isEnabled = false
    isPaused = true;
  }
  func resumeUtterance() {
    debugLog(msg: "|> utterance RESUMED")
    synth.continueSpeaking()
    buttonPauseResume.title = ICON_PAUSE
    buttonPlayStop.isEnabled = true
    isPaused = false;

    logSpeechStats()
  }
  func saveUtteranceToFile() {
    let synthToSave = NSSpeechSynthesizer()
    let utteranceToSave = textToUtter.string
    let curVoice = (APPLE_VOICE_PREFIX + (popupVoices.selectedItem?.title)!)

    synthToSave.setVoice(curVoice)
    synthToSave.rate = opsSpeedSlider.floatValue
    let newPitch = opsPitchSlider.floatValue
    do {
      try synthToSave.setObject(newPitch, forProperty:NSSpeechPitchBaseProperty)
    } catch {
      debugLog(msg: "Could not set synthToSave pitch")
    }
    let newPitchMod = opsPitchModSlider.floatValue
    do {
      try synthToSave.setObject(newPitchMod, forProperty:NSSpeechPitchModProperty)
    } catch {
      debugLog(msg: "Could not set synthToSave pitch mod")
    }
    synthToSave.volume = opsVolumeSlider.floatValue/100

    let homeUrl = NSHomeDirectory()
    var fileString = ""

    if (opsUseTextAsFilename.state == NSOffState) {
      let fileCode = arc4random_uniform(999999999)
      fileString = String(format:"%@/Desktop/utter_%d.aiff", homeUrl, fileCode)
    } else {
      let customName = textToUtter.string
      fileString = String(format: "%@/Desktop/%@.aiff", homeUrl, customName!)
    }
    let fileUrl = NSURL(fileURLWithPath:fileString)
    debugLog(msg: String(format: "fileUrl: %@", fileUrl))
    let speechSaved = synthToSave.startSpeaking(utteranceToSave!, to: fileUrl as URL)
    debugLog(msg: String(format: "utterance sent to file successfully? %d", speechSaved as CVarArg))
  }

  // MARK - IBOutlets
  @IBOutlet var textToUtter: NSTextView!
  @IBOutlet weak var buttonPlayStop: NSButton!
  @IBOutlet weak var buttonPauseResume: NSButton!
  @IBOutlet weak var popupVoices: NSPopUpButton!
  @IBOutlet weak var opsSpeedSlider: NSSlider!
  @IBOutlet weak var opsSpeedText: NSTextField!
  @IBOutlet weak var opsSpeedReset: NSButton!
  @IBOutlet weak var opsPitchSlider: NSSlider!
  @IBOutlet weak var opsPitchText: NSTextField!
  @IBOutlet weak var opsPitchReset: NSButton!
  @IBOutlet weak var opsPitchModSlider: NSSlider!
  @IBOutlet weak var opsPitchModText: NSTextField!
  @IBOutlet weak var opsPitchModReset: NSButton!
  @IBOutlet weak var opsVolumeSlider: NSSlider!
  @IBOutlet weak var opsVolumeText: NSTextField!
  @IBOutlet weak var opsVolumeReset: NSButton!
  @IBOutlet weak var opsButtonResetAll: NSButton!
  @IBOutlet weak var opsSaveToFile: NSButton!
  @IBOutlet weak var opsUseTextAsFilename: NSButton!
  

  // MARK - IBActions
  @IBAction func btnClickPlayStop(_ sender: Any) {
    startStopUtterance()
  }
  @IBAction func btnClickPauseResume(_ sender: Any) {
    pauseResumeUtterance()
  }
  @IBAction func popupVoicesDidChange(_ sender: Any) {
    setSynthVoice()
  }

  @IBAction func opsSpeedSliderDidChange(_ sender: Any) {
    opsSpeedText.stringValue = "\(opsSpeedSlider.intValue)"
    setSynthSpeed()
    if (!isPaused) {
      startUtterance()
    }
  }
  @IBAction func opsPitchSliderDidChange(_ sender: Any) {
    opsPitchText.stringValue = "\(opsPitchSlider.intValue)"
    do {
      try setSynthPitch()
    } catch {
      debugLog(msg: "Could not set synth pitch")
    }
    if (!isPaused) {
      startUtterance()
    }
  }
  @IBAction func opsPitchModSliderDidChange(_ sender: Any) {
    opsPitchModText.stringValue = "\(opsPitchModSlider.intValue)"
    do {
      try setSynthPitchMod()
    } catch {
      debugLog(msg: "Could not set synth pitch mod")
    }
    if (!isPaused) {
      startUtterance()
    }
  }
  @IBAction func opsVolumeSliderDidChange(_ sender: Any) {
    opsVolumeText.stringValue = "\(opsVolumeSlider.intValue)"
    setSynthVolume()
    if (!isPaused) {
      startUtterance()
    }
  }

  @IBAction func opsSpeedResetClicked(_ sender: Any) {
    opsSpeedSlider.intValue = Int32(INITIAL_SPEED)
    opsSpeedText.intValue = Int32(INITIAL_SPEED)

    startStopUtterance()
    startUtterance()
  }
  @IBAction func opsPitchResetClicked(_ sender: Any) {
    opsPitchSlider.intValue = Int32(INITIAL_PITCH)
    opsPitchText.intValue = Int32(INITIAL_PITCH)

    startStopUtterance()
    startUtterance()
  }
  @IBAction func opsPitchModResetClicked(_ sender: Any) {
    opsPitchModSlider.intValue = Int32(INITIAL_PITCHMOD)
    opsPitchModText.intValue = Int32(INITIAL_PITCHMOD)

    startStopUtterance()
    startUtterance()
  }
  @IBAction func opsVolumeResetClicked(_ sender: Any) {
    opsVolumeSlider.intValue = Int32(INITIAL_VOLUME)
    opsVolumeText.intValue = Int32(INITIAL_VOLUME)

    startStopUtterance()
    startUtterance()
  }
  @IBAction func opsResetAllClicked(_ sender: Any) {
    // reset labels and sliders
    opsSpeedSlider.floatValue = Float(INITIAL_SPEED)
    opsSpeedText.floatValue = Float(INITIAL_SPEED)
    opsPitchSlider.floatValue = Float(INITIAL_PITCH)
    opsPitchText.floatValue = Float(INITIAL_PITCH)
    opsPitchModSlider.floatValue = Float(INITIAL_PITCHMOD)
    opsPitchModText.floatValue = Float(INITIAL_PITCHMOD)
    opsVolumeSlider.intValue = Int32(INITIAL_VOLUME)
    opsVolumeText.floatValue = Float(INITIAL_VOLUME)

    // reset synth
    setSynthSpeed()
    setSynthVolume()
    do {
      try setSynthPitch()
    } catch {
      debugLog(msg: "Could not set synth pitch")
    }
    do {
      try setSynthPitchMod()
    } catch {
      debugLog(msg: "Could not set synth pitch mod")
    }

    startStopUtterance()
    startUtterance()
  }
  @IBAction func opsSaveToFileDidToggle(_ sender: Any) {
    debugLog(msg: String(format:"opsSaveToFile toggled to: %ld", opsSaveToFile.state as CLong))
    if (opsSaveToFile.state == NSOnState) {
      opsUseTextAsFilename.isEnabled = true
    } else {
      opsUseTextAsFilename.isEnabled = false
      opsUseTextAsFilename.state = 0
    }
  }
  @IBAction func opsUseTextAsFilenameDidToggle(_ sender: Any) {
    debugLog(msg: String(format:"opsUseTextAsFilename toggled to: %ld", opsUseTextAsFilename.state as CLong))
  }

  // MARK - System Events
  override func viewDidLoad() {
    super.viewDidLoad()
    setupInitialText()
    setupButtonIcons()
    populateVoices()
    setSynthVoice()
    setupOptions()
  }
  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  func speechSynthesizer(_ sender: NSSpeechSynthesizer,
                                  didFinishSpeaking finishedSpeaking: Bool) {
    debugLog(msg: "XXX utterance FINISHED")
    buttonPlayStop.title = ICON_PLAY
    buttonPauseResume.isEnabled = false
  }

  // MARK - Helper Methods
  func logSpeechStats() {
    if (isDebug) {
      NSLog("---------------------");
      NSLog("!!! utterance STARTED");
      NSLog("utteranceVOICE: %@", synth.voice()!)
      NSLog("utteranceRATE: %.2f", synth.rate)
      var utterancePitchBase = 0
      do {
        utterancePitchBase = try synth.object(forProperty: NSSpeechPitchBaseProperty) as! Int
      } catch {
        NSLog("utterancePITCHBASE: cannot be determined")
      }
      NSLog("utterancePITCHBASE: %.2f", utterancePitchBase)
      var utterancePitchMod = 0
      do {
        utterancePitchMod = try synth.object(forProperty: NSSpeechPitchModProperty) as! Int
      } catch {
        NSLog("utterancePITCHMOD: cannot be determined")
      }
      NSLog("utterancePITCHMOD: %.2f", utterancePitchMod)
      NSLog("utteranceVOLUME: %.2f", synth.volume)
    }
  }
  func debugLog(msg: String) {
    if isDebug {
      NSLog(msg)
    }
  }
  func strToArr(str: String) -> Array<String> {
    return str.characters.split{$0 == "."}.map(String.init)
  }
}
