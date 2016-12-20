//
//  UtterlyWindow.swift
//  Utterly
//
//  Created by Michael Chadwick on 11/26/16.
//  Copyright © 2016 Michael Chadwick. All rights reserved.
//

import Cocoa

class UtterlyTextView: NSTextView {
  let vc = ViewController()

  // Allow TextView to receive keypress (remove the purr sound)
  override var acceptsFirstResponder : Bool {
    return true
  }

  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
  }

  // Override the NSTextView keydown func to read keycode of pressed key
  override func keyDown(with theEvent: NSEvent)
  {
    super.keyDown(with: theEvent) // do normal event (e.g. insert character)
    if theEvent.modifierFlags.contains(.command) {
      if theEvent.keyCode == 36 { // Cmd-Enter combo
        NSLog("Cmd-Enter combo hit")
        vc.startStopUtterance()
      }
    }
    if theEvent.modifierFlags.contains(.shift) {
      NSLog("Shift key held down")
    }
    if theEvent.modifierFlags.contains(.control) {
      NSLog("Control key held down")
    }
    if theEvent.modifierFlags.contains(.option) {
      NSLog("Option key held down")
    }
    NSLog("Key pressed \(theEvent.keyCode)")
  }
}

