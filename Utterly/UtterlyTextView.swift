//
//  UtterlyWindow.swift
//  Utterly
//
//  Created by Michael Chadwick on 11/26/16.
//  Copyright © 2016 Michael Chadwick. All rights reserved.
//

import Cocoa

class UtterlyTextView: NSTextView {
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
    let vc = NSApplication.shared().mainWindow?.windowController?.contentViewController as! ViewController
    super.keyDown(with: theEvent) // do normal event (e.g. insert character)
    if theEvent.modifierFlags.contains(.command) {
      if theEvent.keyCode == 36 { // Cmd-Enter combo
        vc.debugLog(msg: "Cmd-Enter combo hit")
        vc.startUtterance()
      }
    }
    if theEvent.modifierFlags.contains(.shift) {
      vc.debugLog(msg: "Shift key held down")
    }
    if theEvent.modifierFlags.contains(.control) {
      vc.debugLog(msg: "Control key held down")
    }
    if theEvent.modifierFlags.contains(.option) {
      vc.debugLog(msg: "Option key held down")
    }
    vc.debugLog(msg: "Key hit: \(theEvent.keyCode)")
  }
}

