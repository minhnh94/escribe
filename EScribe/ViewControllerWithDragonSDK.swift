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

class ViewControllerWithDragonSDK: UIViewController, UITextFieldDelegate, UITextViewDelegate, NUSASessionDelegate, NUSAVuiControllerDelegate {

    // MARK: - API related data
    let kMyPartnerGuid = "da76b0a6-3428-4f0f-b1d0-f8d20909ffa9"
    let kMyOrganizationToken = "529363f9-68b8-456a-b57c-ce149676e7b4"
    let kApplicationName = "eScribe"
    let kUserId = "User66aa8c2a-36df-46db-88e5-0a2a811f2ed4"
    
    // MARK: - Controller properties
    var vuiController: NUSAVuiController!
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
        NUSASession.shared().open(forApplication: kApplicationName, partnerGuid: kMyPartnerGuid, licenseGuid: kMyOrganizationToken, userId: kUserId)
        NUSASession.shared().delegate = self
        
        uuid = "\(currentPatient.firstName!) \(currentPatient.lastName!)_\(title!)_\(VariousHelper.shared.getTodayAsFullString())"
        
        setupEditIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vuiController =  NUSAVuiController(view: self.view)
        
        vuiController.synchronizeWithView()
        vuiController.delegate = self
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
                    let inputField = view.viewWithTag(tagNum!)
                    if inputField is UITextField {
                        let textField = inputField as! UITextField
                        textField.text = dictValue
                    } else if inputField is UITextView {
                        let textView = inputField as! UITextView
                        textView.text = dictValue
                    }
                } else {
                    let textView = view.viewWithTag(tagNum!) as! UITextView
                    textView.text = dictValue
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NUSASession.shared().stopRecording()
        AudioRecordHelper.shared.stopRecording()
        vuiController.delegate = nil
        vuiController = nil
        NUSASession.shared().delegate = nil
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
            do {
                try NUSASession.shared().startRecording()
            } catch let error {
                print("cannot start record because \(error.localizedDescription)")
            }
        } else {
            NUSASession.shared().stopRecording()
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
    
    func sessionDidStartRecording() {
        isRecording = true
        changeInterface()
        statusNotifyTextField.text = "Recording"
        numOfRecording += 1
        AudioRecordHelper.shared.record(filename: "\(uuid)-p\(numOfRecording)")
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor(red:204.0/255.0, green:204.0/255.0, blue:204.0/255.0, alpha:255.0/255.0)
    }
    
    func sessionDidStopRecording() {
        isRecording = false
        changeInterface()
        currentProcessingText?.resignFirstResponder()
        currentProcessingText = nil
        submitButton.isEnabled = true
        submitButton.backgroundColor = UIColor(red:0.0/255.0, green:123.0/255.0, blue:207.0/255.0, alpha:255.0/255.0)
        AudioRecordHelper.shared.stopRecording()
    }
    
    // MARK: - Privates
    
    private func getXMLResultString() -> String {
        let patientNote = AEXMLDocument()
        
        let informationChild = patientNote.addChild(name: "information")
        
        if tagDictionaryChoice == 1 {
            for (key, tag) in NameTagAssociation.nameTagDictionary {
                let inputField = view.viewWithTag(tag)
                if inputField is UITextField {
                    let textField = inputField as! UITextField
                    if textField.text != "" {
                        informationChild.addChild(name: key.replacingOccurrences(of: " ", with: "_"), value: textField.text)
                    }
                } else if inputField is UITextView {
                    let textView = inputField as! UITextView
                    if textView.text != "" {
                        informationChild.addChild(name: key.replacingOccurrences(of: " ", with: "_"), value: textView.text)
                    }
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

