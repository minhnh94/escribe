//
//  ViewController.swift
//  EScribe
//
//  Created by minhnh on 2/14/17.
//
//

import UIKit
import QuartzCore
import AEXML
import SpeechKit

class ViewControllerWithDragonSDK: UIViewController, UITextFieldDelegate, UITextViewDelegate, SKTransactionDelegate {

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
    var numOfRecording: Int = 0
    var uuid = ""    // Unique ID for naming audio files
    var tagDictionaryChoice = 1     // Use for manipulating tag association, also use as note input type
    var editedPatientNote: PatientNote?
    
    // MARK: - UI properties
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statusNotifyTextField: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    
    // MARK: - Controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInterface()
        // Init Speech-to-text session
        SERVER_URL = String(format: "nmsps://%@@%@:%@", APP_ID, SSL_HOST, SSL_PORT)
        skSession = SKSession(url: URL(string: SERVER_URL), appToken: APP_KEY)
        
        uuid = "\(currentPatient.firstName!) \(currentPatient.lastName!)_\(title!)_\(VariousHelper.shared.getTodayAsFullString())"
        
        setupEditIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupInterface() {
        patientNameLabel.text = currentPatient.firstName + " " + currentPatient.lastName
        dobLabel.text = currentPatient.dob
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
    }
    
    private func setupEditIfNeeded() {
        if let uEditedPatientNote = editedPatientNote {
            tagDictionaryChoice = uEditedPatientNote.storedType
            uuid = uEditedPatientNote.allNoteContents.first!.noteId
            numOfRecording = uEditedPatientNote.voiceRecIndex
            title = uEditedPatientNote.allNoteContents.first!.noteType
            
            let dictionary = VariousHelper.shared.convertXMLStringToDictionary(xmlString: uEditedPatientNote.allNoteContents.first!.content)
            let fieldTagDictionary = tagDictionaryChoice == 1 ? NameTagAssociation.nameTagDictionary : NameTagAssociation.blankTagDictionary
            for (dictKey, dictValue) in dictionary {
                let tagNum = fieldTagDictionary[dictKey]
                if tagDictionaryChoice == 1 {
                    let textField = view.viewWithTag(tagNum!) as! UITextField
                    textField.text = dictValue
                } else {
                    let textView = view.viewWithTag(tagNum!) as! UITextView
                    textView.text = dictValue
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AudioRecordHelper.shared.stopRecording()
    }
    
    private func additionalStyling() {
        submitButton.layer.borderWidth = 0
        submitButton.layer.cornerRadius = 14.0
        submitButton.clipsToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func toggleRecord(_ sender: UIButton) {
        isRecording = !isRecording
        changeInterface()
        
        voiceRecognitionTransactionStarted()
    }
    
    func changeInterface() {
        if isRecording {
            statusNotifyTextField.text = "Preparing..."
            recordButton.setBackgroundImage(#imageLiteral(resourceName: "bt_stop record"), for: .normal)
        } else {
            statusNotifyTextField.text = "Inactive"
            recordButton.setBackgroundImage(#imageLiteral(resourceName: "bt_start record"), for: .normal)
        }
    }
    
    func voiceRecognitionTransactionStarted() {
        if isRecording {
            let options = [SKTransactionResultDeliveryKey: SKTransactionResultDeliveryProgressive];
            skTransaction = skSession!.recognize(withType: SKTransactionSpeechTypeDictation, detection: .none, language: "eng-USA", options: options, delegate: self)
        } else {
            skTransaction?.stopRecording()
        }
    }
    
    @IBAction func saveClicked(_ sender: UIBarButtonItem) {
        var result = 0
        if editedPatientNote == nil {
            result = PatientNote.savePatientNoteToDisk(patient: currentPatient, storedType: tagDictionaryChoice, voiceRecIndex: numOfRecording)
        } else {
            result = PatientNote.savePatientNoteToDisk(patient: currentPatient, storedType: tagDictionaryChoice, voiceRecIndex: numOfRecording, loadFromPatientNoteId: editedPatientNote!.bigNoteId)
        }
        let xmlString = getXMLResultString()
        NoteContent.createNoteContent(patientNoteId: result, noteContentId: uuid, noteType: self.title!, content: xmlString)
        
        let alertVC = UIAlertController(title: "", message: "Saving draft finished.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func submitClicked(_ sender: UIButton) {
        AudioRecordHelper.shared.mergeAudioFiles(uuid: uuid, numOfParts: numOfRecording, completionHandler: {
            var result = 0
            if self.editedPatientNote == nil {
                result = PatientNote.createNewPatientNote(patient: self.currentPatient)
            } else {
                result = PatientNote.createNewPatientNote(patient: self.currentPatient, loadFromPatientNoteId: self.editedPatientNote!.bigNoteId)
            }
            let xmlString = self.getXMLResultString()
            let patientNoteSavePath = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(self.uuid).txt")
            do {
                let readableString = self.exportPatientInfoToString() + VariousHelper.shared.convertXMLStringToReadableString(xmlString: xmlString)
                try readableString.write(to: patientNoteSavePath, atomically: false, encoding: .utf8)
            } catch let error {
                print("Cannot write xml file: \(error.localizedDescription)")
            }
            NoteContent.createNoteContent(patientNoteId: result, noteContentId: self.uuid, noteType: self.title!, content: xmlString)
            
            let alertVC = UIAlertController(title: "", message: "Submitting finished.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alertVC, animated: true, completion: nil)
        })
    }
    
    // MARK: - Text field delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentProcessingText = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentProcessingText = nil
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        currentProcessingText = textView
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        currentProcessingText = nil
        return true
    }
    
    // MARK: - SpeechKit Delegates
    
    func transactionDidBeginRecording(_ transaction: SKTransaction!) {
        isRecording = true
        changeInterface()
        statusNotifyTextField.text = "Recording"
        numOfRecording += 1
        AudioRecordHelper.shared.record(filename: "\(uuid)-p\(numOfRecording)")
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor(red:204.0/255.0, green:204.0/255.0, blue:204.0/255.0, alpha:255.0/255.0)
    }

    func transactionDidFinishRecording(_ transaction: SKTransaction!) {
        isRecording = false
        changeInterface()
        currentProcessingText?.resignFirstResponder()
        currentProcessingText = nil
        submitButton.isEnabled = true
        submitButton.backgroundColor = UIColor(red:0.0/255.0, green:123.0/255.0, blue:207.0/255.0, alpha:255.0/255.0)
        AudioRecordHelper.shared.stopRecording()
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
                    let inputField = view.viewWithTag(tag) as! UITextField
                    inputField.becomeFirstResponder()
                    
                    startSelectingField = false
                }
            }
        }
        
        if let currentProcessingElement = currentProcessingText {
            let aField = currentProcessingElement as! UITextField
            aField.text = topRecognitionText
        }
    }
    
    // MARK: - Privates
    
    private func getXMLResultString() -> String {
        let patientNote = AEXMLDocument()
        
        let informationChild = patientNote.addChild(name: "information")
        
        if tagDictionaryChoice == 1 {
            for (key, tag) in NameTagAssociation.nameTagDictionary {
                let inputField = view.viewWithTag(tag) as! UITextField
                if inputField.text != "" {
                    informationChild.addChild(name: key.replacingOccurrences(of: " ", with: "_"), value: inputField.text)
                }
            }
        } else if tagDictionaryChoice == 2 {
            for (key, tag) in NameTagAssociation.blankTagDictionary {
                let inputField = view.viewWithTag(tag) as! UITextView
                if inputField.text != "" {
                    informationChild.addChild(name: key.replacingOccurrences(of: " ", with: "_"), value: inputField.text)
                }
            }
        }
        
        return patientNote.xml
    }
    
    private func exportPatientInfoToString() -> String {
        var result = ""
        
        result = "Patient name: \(currentPatient.firstName!) \(currentPatient.lastName!)\nDate of birth: \(currentPatient.dob!) (\(currentPatient.getYearsOld()) years old)\nAMD ID: \(currentPatient.amdid!)\nGender: \(currentPatient.gender!)\nPhone: \(currentPatient.phone!)\nAddress: \(currentPatient.address!), \(currentPatient.city!), \(currentPatient.state!), \(currentPatient.zipcode!)\n\n"
        
        return result
    }
}

