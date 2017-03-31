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

class ViewControllerWithDragonSDK: UIViewController, UITextFieldDelegate, NUSASessionDelegate, NUSAVuiControllerDelegate {

    // MARK: - API related data
    let kMyPartnerGuid = "da76b0a6-3428-4f0f-b1d0-f8d20909ffa9"
    let kMyOrganizationToken = "529363f9-68b8-456a-b57c-ce149676e7b4"
    let kApplicationName = "eScribe"
    let kUserId = "User66aa8c2a-36df-46db-88e5-0a2a811f2ed4"
    
    // MARK: - Controller properties
    var vuiController: NUSAVuiController!
    var currentProcessingText: UITextField?
    var isRecording: Bool = false
    var startSelectingField = true
    var currentPatient: Patient!
    var numOfRecording: Int = 0
    let uuid = UUID().uuidString    // Unique ID for naming audio files
    
    // MARK: - UI properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var statusNotifyTextField: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    
    // MARK: - Controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Speech-to-text session
        NUSASession.shared().open(forApplication: kApplicationName, partnerGuid: kMyPartnerGuid, licenseGuid: kMyOrganizationToken, userId: kUserId)
        NUSASession.shared().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vuiController =  NUSAVuiController(view: self.view)
        vuiController.synchronizeWithView()
        vuiController.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        vuiController = nil
        NUSASession.shared().delegate = nil
    }
    
    private func additionalStyling() {
        submitButton.layer.cornerRadius = 14.0
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
            AudioRecordHelper.shared.stop()
        }
    }
    
    @IBAction func submitClicked(_ sender: UIButton) {
        AudioRecordHelper.shared.mergeAudioFiles(uuid: uuid, numOfParts: numOfRecording, completionHandler: {            
            let result = PatientNote.createNewPatientNote(patient: self.currentPatient)
            let xmlString = self.getXMLResultString()
            NoteContent.createNoteContent(patientNoteId: result, noteContentId: self.uuid, content: xmlString)
        })
    }
    
    // MARK: - Text field delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
//        scrollView.scrollRectToVisible(textField.frame, animated: true)
        currentProcessingText = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentProcessingText = nil
        return true
    }
    
    // MARK: - SpeechKit Delegates
    
    func sessionDidStartRecording() {
        isRecording = true
        changeInterface()
        statusNotifyTextField.text = "00:00:00"
        AudioRecordHelper.shared.record(filename: "\(uuid)-p\(numOfRecording)")
    }
    
    func sessionDidStopRecording() {
        isRecording = false
        changeInterface()
        currentProcessingText?.resignFirstResponder()
        currentProcessingText = nil
    }
    
    // MARK: - Privates
    
    private func getXMLResultString() -> String {
        let patientNote = AEXMLDocument()
        
        for (key, tag) in NameTagAssociation.nameTagDictionary {
            let inputField = view.viewWithTag(tag) as! UITextField
            if inputField.text != "" {
                patientNote.addChild(name: key.replacingOccurrences(of: " ", with: "_"), value: inputField.text)
            }
        }
        
        return patientNote.xml
    }
}

