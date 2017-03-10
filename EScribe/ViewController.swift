//
//  ViewController.swift
//  EScribe
//
//  Created by minhnh on 2/14/17.
//
//

import UIKit
import SpeechKit
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, SKTransactionDelegate, AVAudioRecorderDelegate {

    // MARK: - API related data
    let API_URL = "nmsps://NMDPTRIAL_minhnh_da_gmail_com20170206055537@sslsandbox-nmdp.nuancemobility.net:443"
    let SSL_HOST = "sslsandbox-nmdp.nuancemobility.net"
    let SSL_PORT = "443"
    let APP_ID = "NMDPTRIAL_minhnh_da_gmail_com20170206055537"
    let APP_KEY = "9b35dcfe5ce50ab03bd366d929f2c775cedc1b88ab44b13340625481bc104357461f55a20460534033b9195cabe1d17abdec026930b39c7115f0f2d101352847"
    var SERVER_URL: String!
    
    // MARK: - Controller properties
    var skSession: SKSession?
    var skTransaction: SKTransaction?
    var audioSession: AVAudioSession?
    var audioRec: AVAudioRecorder?
    var currentProcessingText: UIView?
    var isRecording: Bool = false
    
    // MARK: - UI properties
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statusNotifyTextField: UILabel!
    
    // MARK: - Controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init Speech-to-text session
        SERVER_URL = String(format: "nmsps://%@@%@:%@", APP_ID, SSL_HOST, SSL_PORT)
        skSession = SKSession(url: URL(string: SERVER_URL), appToken: APP_KEY)
        
        // Init recorder session
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession?.setActive(true)
            
            audioSession?.requestRecordPermission({ (allowed) in
                if allowed {
                    print("Mic authorized")
                } else {
                    print("Mic access declined")
                }
            })
        } catch {
            print("Failed to init AV session")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleRecord(_ sender: UIButton) {
        isRecording = !isRecording
        if isRecording {
            statusNotifyTextField.text = "Preparing..."
            recordButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
            voiceRecognitionTransactionStarted()
        } else {
            statusNotifyTextField.text = "The recorder is inactive"
            recordButton.setBackgroundImage(#imageLiteral(resourceName: "record"), for: .normal)
            skTransaction?.stopRecording()
        }
    }
    
    func voiceRecognitionTransactionStarted() {
        let options = [SKTransactionResultDeliveryKey: SKTransactionResultDeliveryProgressive];
        skTransaction = skSession!.recognize(withType: SKTransactionSpeechTypeDictation, detection: .none, language: "eng-USA", options: options, delegate: self)
    }
    
    func audioRecording() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirect = paths[0]
        
        let writePath = docDirect.appendingPathComponent("fileName.aac")
        let audioUrl = URL.init(fileURLWithPath: writePath.path)
        
        let settings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000.0,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            audioRec = try AVAudioRecorder(url: audioUrl, settings: settings)
            audioRec?.delegate = self
            audioRec?.isMeteringEnabled = true
            audioRec?.prepareToRecord()
            audioRec?.record()
        } catch let error {
            print(error)
        }
    }
    
    // MARK: - Audio delegates
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Success lol")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Fail lol")
    }
    
    // MARK: - Text field delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentProcessingText = textField
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentProcessingText = textView
    }
    
    // MARK: - SKTransaction delegates
    
    func transactionDidBeginRecording(_ transaction: SKTransaction!) {
        statusNotifyTextField.text = "Now recording, please speak..."
        audioRecording()
    }
    
    func transactionDidFinishRecording(_ transaction: SKTransaction!) {
        audioRec?.stop()
    }
    
    func transaction(_ transaction: SKTransaction!, didReceive recognition: SKRecognition!) {
        let topRecognitionText = recognition.text
        
        // Testing
        let lastObj = recognition.details.first as! SKRecognizedPhrase
        let word = lastObj.words.first as! SKRecognizedWord
        print(word.text)
        
        
        if let currentProcessingElement = currentProcessingText {
            if currentProcessingElement is UITextField {
                let textField = currentProcessingElement as! UITextField
                textField.text = topRecognitionText
            } else if currentProcessingElement is UITextView {
                let textView = currentProcessingElement as! UITextView
                textView.text = topRecognitionText
            }
        }
    }
    
}

