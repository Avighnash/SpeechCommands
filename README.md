# SpeechCommands

SpeechCommands is a wrapper, or utility, that utilizes the Speech framework provided by Swift.

Example: User says "hello", Speech framework translates that into text, and finally, SpeechCommands checks if a command is registered with that text, and executes an action.

This was mashed together by me in a couple of hours, it's not perfect, so if you encounter any bugs, or any bad stuff happens, pls don't kill me xD

Installation:
Just download the files and import them into your project. 

Usage:
```Swift
import UIKit

class ViewController: UIViewController {
    
    // Create session instance
    let session = SCommandSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create commands
        let hello = Command(command: "hello")
        hello.response {
            print("hello!") // Do whatever you want here
        }
        
        let greeting = Command(command: "How are you")
        greeting.response {
            print("im good! ty for asking <3")
        }
        
        // Register commands
        session.register(hello, greeting)
        
        // Additional methods
        session.remove(_ command: Command)
       
        session.stop() // Ends session
    }
    
    @IBAction func button(_ sender: UIButton) {
        // Start recording session
        session.start()
        
        print("started")
    }
}
```

TODO:
- Command alias support

(if you have any suggestions tell me here)

Thanks!
