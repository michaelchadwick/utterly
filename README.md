# utterly
Make your Mac utter, now in Swift (major rewrite of [Utter](https://github.com/michaelchadwick/utter))

### Why Make This App (Again)?
I'd had fun making [Utter](https://github.com/michaelchadwick/utter), but ran into some issues that I couldn't solve in its native Objective-C. Also, I wanted to write a modern Swift 3 app. So...I made **Utterly**.

### Features
* Simple GUI on top of _NSSpeechSynthesizer_. Enter text, and then either press &#8984;-Enter or click the play button to hear it.
* Stop, pause and resume speech.
* Change the voice, speed/rate, pitch, pitchmod, or volume of the speech synthesis. Speech updates automatically as options change.
* Save the speech to an AIFF on your desktop. Use the text itself as the filename, if you wish.
* A picture of a cow!

### Contributing
Clone the repo and build the Xcode project. It was created in **Xcode 8**, and was targeted to **macOS 10.2**,  but _may_ work in earlier versions.
