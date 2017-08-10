import UIKit
import AVKit
import Speech

class SCommandSession: NSObject, SFSpeechRecognizerDelegate {
    
    var commands: [Command] = []
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
                
            case .denied:
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
        }
    }
    
    func start() {
        startSpeech()
    }
    
    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
        }
    }
    
    func startSpeech() {
        
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
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil {
                
                if let text = result?.bestTranscription.formattedString {
                    
                    self.commands.forEach({ (cmd) in
                        if text.lowercased() == cmd.command.lowercased() {
                            
                            cmd.action!()
                            self.stop()
                        }
                    })
                    
                    isFinal = (result?.isFinal)!
                }
            }
            
            if error != nil || isFinal {
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func register(_ cmds: Command...) {
        cmds.forEach { (cmd) in
            if !commands.contains(where: { $0.command == cmd.command }) {
                commands.append(cmd)
            }
        }
    }
    
    func remove(_ command: Command) {
        if commands.contains(where: { $0.command == command.command }) {
            commands = commands.filter { $0.command != command.command }
        }
    }
}

