//
//  NewNoteController.swift
//  EScribe
//
//  Created by minhnh on 3/20/17.
//
//

import UIKit
import MediaPlayer
import SVProgressHUD

class NewNoteController: UIViewController, UITableViewDataSource, UITableViewDelegate, SubmitAudioDelegate {

    let newNoteTypeArray = ["General", "PCP", "Cardiology", "Blank note", "Continue editing"]     // More will be added on demand
    var currentPatient: Patient!
    var toBeEditedPatientNote: PatientNote?
    var usedParseFunction = 0
    
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    @IBOutlet weak var noteTypeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupInterface() {
        patientNameLabel.text = currentPatient.firstName + " " + currentPatient.lastName
        dobLabel.text = currentPatient.dob
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
    }
    
    // MARK: - Actions
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func parseClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToParseFileVC", sender: nil)
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newNoteTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewNoteTypeCell", for: indexPath)
        
        cell.textLabel?.text = newNoteTypeArray[indexPath.row]
        
        if toBeEditedPatientNote != nil {
            if indexPath.row != newNoteTypeArray.count - 1 {
                cell.isUserInteractionEnabled = false
                cell.textLabel?.textColor = UIColor.lightGray
            } else {
                cell.isUserInteractionEnabled = true
                cell.textLabel?.textColor = UIColor.black
            }
        } else {
            if indexPath.row != newNoteTypeArray.count - 1 {
                cell.isUserInteractionEnabled = true
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.isUserInteractionEnabled = false
                cell.textLabel?.textColor = UIColor.lightGray
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == newNoteTypeArray.count - 2) {
            performSegue(withIdentifier: "ToBlankNoteVC", sender: indexPath)
        } else {
            if let uEditedPatientNote = toBeEditedPatientNote {
                if uEditedPatientNote.storedType == 1 {
                    performSegue(withIdentifier: "ToInputNoteVC", sender: indexPath)
                } else {
                    performSegue(withIdentifier: "ToBlankNoteVC", sender: indexPath)
                }
            } else {
                performSegue(withIdentifier: "ToInputNoteVC", sender: indexPath)
            }
        }
    }
    
    // MARK: - Parse audio delegate
    
    func didSubmitAudioFileWithPath(_ path: String) {
        if path == "" {
            UIAlertView(title: "", message: "We found no recorded file to submit. Maybe you haven't recorded yet.", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            let api = ApiHelper()
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show(withStatus: "Generating form...")
            api.sendAudioFileToNuance(fileUrl: URL(fileURLWithPath: path)) { (response) in
                if let uString = response {
                    self.usedParseFunction = 1
                    try! FileManager.default.removeItem(atPath: path)
                    self.performSegue(withIdentifier: "ToInputNoteVC", sender: uString)
                }
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "ToParseFileVC" {
            if (usedParseFunction == 1) {
                let transcribedString = sender as! String
                let vc = segue.destination as! GeneralNoteController
                
                embedResultIntoViewController(vc, transcribedString: transcribedString)
                
                SVProgressHUD.dismiss()
            } else {
                let indexPath = sender as! IndexPath
                
                let vc = segue.destination as! ViewControllerWithDragonSDK
                vc.title = newNoteTypeArray[indexPath.row]
                vc.currentPatient = currentPatient
                vc.editedPatientNote = toBeEditedPatientNote
            }
        } else {
            let vc = segue.destination as! StreamingInputController
            vc.delegate = self
        }
    }
    
    private func embedResultIntoViewController(_ vc: GeneralNoteController, transcribedString: String) {
        vc.title = "General"
        vc.currentPatient = currentPatient
        vc.editedPatientNote = toBeEditedPatientNote
        
        var indexOfField = 100
        
        for sentence in tokenizeString(aString: sentencifyString(aString: transcribedString)) {
            if sentence.hasPrefix("next field") {
                indexOfField = indexOfField + 1 > 141 ? 100 : indexOfField + 1
            } else if sentence.hasPrefix("previous field") {
                indexOfField = indexOfField - 1 < 100 ? 141 : indexOfField - 1
            } else if sentence.hasPrefix("go to") {
                var detachedSentence = sentence.replacingOccurrences(of: "go to ", with: "")
                for fieldKey in NameTagAssociation.nameTagDictionary.keys {
                    if detachedSentence.hasPrefix(fieldKey) {
                        detachedSentence = detachedSentence.replacingOccurrences(of: fieldKey, with: "")
                        indexOfField = NameTagAssociation.nameTagDictionary[fieldKey]!
                        
                        let inputField = vc.view.viewWithTag(indexOfField)
                        if inputField is UITextField {
                            let textField = inputField as! UITextField
                            textField.text = detachedSentence
                        } else if inputField is UITextView {
                            let textView = inputField as! UITextView
                            textView.text = detachedSentence
                        }
                    }
                }
            } else {
                let inputField = vc.view.viewWithTag(indexOfField)
                if inputField is UITextField {
                    let textField = inputField as! UITextField
                    textField.text = sentence
                } else if inputField is UITextView {
                    let textView = inputField as! UITextView
                    textView.text = sentence
                }
            }
        }
    }
    
    private func sentencifyString(aString: String) -> String {
        var result = aString.lowercased().replacingOccurrences(of: "go to", with: ".go to")
        result = result.replacingOccurrences(of: "next field", with: ".next field.")
        result = result.replacingOccurrences(of: "previous field", with: ".previous field.")
        result = result.replacingOccurrences(of: "stop recording", with: "")
        
        return result
    }
    
    private func tokenizeString(aString: String) -> [String] {
        var arrayResult = aString.components(separatedBy: ".")
        if let firstString = arrayResult.first {
            if firstString == "" {
                arrayResult.remove(at: 0)
            }
        }
        
        return arrayResult
    }
}
