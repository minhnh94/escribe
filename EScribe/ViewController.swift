//
//  ViewController.swift
//  EScribe
//
//  Created by minhnh on 2/14/17.
//
//

import UIKit
import SpeechKit

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, SKTransactionDelegate {

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
    var currentProcessingText: UIView?
    var isRecording: Bool = false
    var startSelectingField = true
    var currentPatient: Patient!
    
    // MARK: - UI properties
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statusNotifyTextField: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    
    // MARK: - Controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Init Speech-to-text session
        SERVER_URL = String(format: "nmsps://%@@%@:%@", APP_ID, SSL_HOST, SSL_PORT)
        skSession = SKSession(url: URL(string: SERVER_URL), appToken: APP_KEY)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleRecord(_ sender: UIButton) {
        isRecording = !isRecording
        if isRecording {
            statusNotifyTextField.text = "Preparing..."
            recordButton.setBackgroundImage(#imageLiteral(resourceName: "bt_stop record"), for: .normal)
            voiceRecognitionTransactionStarted()
        } else {
            statusNotifyTextField.text = "Inactive"
            recordButton.setBackgroundImage(#imageLiteral(resourceName: "bt_start record"), for: .normal)
            skTransaction?.stopRecording()
        }
    }
    
    func voiceRecognitionTransactionStarted() {
        let options = [SKTransactionResultDeliveryKey: SKTransactionResultDeliveryProgressive];
        skTransaction = skSession!.recognize(withType: SKTransactionSpeechTypeDictation, detection: .none, language: "eng-USA", options: options, delegate: self)
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
        statusNotifyTextField.text = "00:00:00"
        AudioRecordHelper.shared.record(filename: "test")
    }
    
    func transactionDidFinishRecording(_ transaction: SKTransaction!) {
        AudioRecordHelper.shared.stop()
    }
    
    func transaction(_ transaction: SKTransaction!, didFinishWithSuggestion suggestion: String!) {
        startSelectingField = true
        currentProcessingText?.resignFirstResponder()
        currentProcessingText = nil
    }
    
    func transaction(_ transaction: SKTransaction!, didReceive recognition: SKRecognition!) {
        let topRecognitionText = recognition.text
        
        if startSelectingField {
            for (key, tag) in NameTagAssociation.nameTagDictionary {
                if topRecognitionText!.lowercased().range(of: key) != nil {
                    let inputField = view.viewWithTag(tag)
                    if inputField is UITextView {
                        let txtView = inputField as! UITextView
                        txtView.becomeFirstResponder()
                        
                        startSelectingField = false
                    } else if inputField is UITextField {
                        let txtField = inputField as! UITextField
                        txtField.becomeFirstResponder()
                        
                        startSelectingField = false
                    }
                }
            }
        }
        
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

