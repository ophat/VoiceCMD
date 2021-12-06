//
//  ViewController.swift
//  VoiceCmd
//
//  Created by Ophat.Phu on 6/12/2564 BE.
//

import UIKit
import Speech

class ViewController: UIViewController {

    var audioEngine = AVAudioEngine()
    let recognizer = SFSpeechRecognizer()
    var recognitionTask:SFSpeechRecognitionTask?
    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var textArea: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         
        requestPermissions()
    }

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("speech authorized")
                } else {
                    print("speech declined.")
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
            if granted {
                print("audio authorized")
            } else {
                print("audio declined.")
            }
        });
    }

    func start() {
        print("start")
        
        audioEngine = AVAudioEngine()
        
        //Change / Edit Start
          do {
              try audioSession.setCategory(AVAudioSession.Category.record)
              try audioSession.setMode(AVAudioSession.Mode.measurement)
              try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
          } catch {
              print("audioSession properties weren't set because of an error.")
          }
        
          let node = audioEngine.inputNode
          let recordingFormat = node.outputFormat(forBus: 0)
          node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
              self.recognitionRequest.append(buffer)
          }

          // Prepare and start recording
          audioEngine.prepare()
          do {
              try audioEngine.start()
          } catch {
              return print(error)
          }
        
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { (result, error) in
            guard let result = result else {
                return
            }
            
            if result.isFinal{
                print(result.bestTranscription.formattedString)
            }
            self.textArea.text = result.bestTranscription.formattedString
            self.doVoiceCMD(sentence: self.textArea.text)
        }
    }
    
    func stop(){
        recognitionTask?.finish()
        audioEngine.stop()
    }
   
    func reset(){
        self.textArea.text = ""
    }
    
    @IBAction func resetBTN(_ sender: Any) {
        self.reset()
    }
    
    @IBAction func stopBTN(_ sender: Any) {
        self.stop()
    }
    
    @IBAction func startBTN(_ sender: Any) {
        self.reset()
        self.stop()
        self.start()
    }
    
    func doVoiceCMD(sentence:String){
        if(sentence.contains("engine reset")){
            self.reset()
        }
        
        if(sentence.contains("engine stop")){
            self.stop()
        }
        
    }
}

