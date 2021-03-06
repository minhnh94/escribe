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
        
        setupInterface()
        // Init Speech-to-text session
        NUSASession.shared().open(forApplication: kApplicationName, partnerGuid: kMyPartnerGuid, licenseGuid: kMyOrganizationToken, userId: kUserId)
        NUSASession.shared().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        vuiController =  NUSAVuiController(view: self.view)
        
        setupDictateCommandForTextFields()
        
        vuiController.synchronizeWithView()
        vuiController.delegate = self
        
    }
    
    private func setupInterface() {
        patientNameLabel.text = currentPatient.firstName + " " + currentPatient.lastName
        dobLabel.text = currentPatient.dob
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
    }
    
    private func setupDictateCommandForTextFields() {
        for (key, tag) in NameTagAssociation.nameTagDictionary {
            let inputField = view.viewWithTag(tag) as! UITextField
            inputField.setVuiConceptName("\(key)")
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
    
    @IBAction func resetClicked(_ sender: UIBarButtonItem) {
        for (_, tag) in NameTagAssociation.nameTagDictionary {
            let inputField = view.viewWithTag(tag) as! UITextField
            inputField.text = ""
        }
    }
    
    @IBAction func submitClicked(_ sender: UIButton) {
        AudioRecordHelper.shared.mergeAudioFiles(uuid: uuid, numOfParts: numOfRecording, completionHandler: {            
            let result = PatientNote.createNewPatientNote(patient: self.currentPatient)
            let xmlString = self.getXMLResultString()
            let patientNoteSavePath = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(self.uuid).txt")
            do {
                let readableString = VariousHelper.shared.convertXMLStringToReadableString(xmlString: xmlString)
                try readableString.write(to: patientNoteSavePath, atomically: false, encoding: .utf8)
            } catch let error {
                print("Cannot write xml file: \(error.localizedDescription)")
            }
            NoteContent.createNoteContent(patientNoteId: result, noteContentId: self.uuid, noteType: self.title!, content: xmlString)
            
            let alertVC = UIAlertController(title: "", message: "Submitting finished.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true);
            }))
            
            self.present(alertVC, animated: true, completion: nil)
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
        for (key, tag) in NameTagAssociation.nameTagDictionary {
            let inputField = view.viewWithTag(tag) as! UITextField
            if inputField.text != "" {
                informationChild.addChild(name: key.replacingOccurrences(of: " ", with: "_"), value: inputField.text)
            }
        }
        
        return patientNote.xml
    }
}

