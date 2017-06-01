//
//  NewPatientController.swift
//  EScribe
//
//  Created by minhnh on 4/10/17.
//
//

import UIKit

class NewPatientController: UIViewController {

    let fieldWithTag = [
        "amdid": 100,
        "firstname": 101,
        "lastname": 102,
        "dob": 103,
        "us_state": 104,
        "city": 105,
        "zipcode": 106,
        "phone": 107,
        "address": 108
    ]
    
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    var editedPatient: Patient?
    
    // MARK: - VC stuffs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        processingEditIfNeeded()
    }

    func processingEditIfNeeded() {
        if let patient = editedPatient {
            let fAmdid = view.viewWithTag(fieldWithTag["amdid"]!) as! UITextField
            let fFirstname = view.viewWithTag(fieldWithTag["firstname"]!) as! UITextField
            let fLastname = view.viewWithTag(fieldWithTag["lastname"]!) as! UITextField
            let fDob = view.viewWithTag(fieldWithTag["dob"]!) as! UITextField
            let fState = view.viewWithTag(fieldWithTag["us_state"]!) as! UITextField
            let fCity = view.viewWithTag(fieldWithTag["city"]!) as! UITextField
            let fZipcode = view.viewWithTag(fieldWithTag["zipcode"]!) as! UITextField
            let fPhone = view.viewWithTag(fieldWithTag["phone"]!) as! UITextField
            let fAddress = view.viewWithTag(fieldWithTag["address"]!) as! UITextField
            
            // For security reason disable the ability to edit this field
            fAmdid.isEnabled = false
            
            fAmdid.text = patient.amdid
            fFirstname.text = patient.firstName
            fLastname.text = patient.lastName
            fDob.text = patient.dob
            fState.text = patient.state
            fCity.text = patient.city
            fZipcode.text = patient.zipcode
            fPhone.text = patient.phone
            fAddress.text = patient.address
            
            if patient.gender == "Male" {
                genderSegment.selectedSegmentIndex = 0
            } else {
                genderSegment.selectedSegmentIndex = 1
            }
        }
    }
    
    // MARK: - Bar btn actions
    
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBtnClicked(_ sender: UIBarButtonItem) {
        let fAmdid = view.viewWithTag(fieldWithTag["amdid"]!) as! UITextField
        let fFirstname = view.viewWithTag(fieldWithTag["firstname"]!) as! UITextField
        let fLastname = view.viewWithTag(fieldWithTag["lastname"]!) as! UITextField
        let fDob = view.viewWithTag(fieldWithTag["dob"]!) as! UITextField
        let fState = view.viewWithTag(fieldWithTag["us_state"]!) as! UITextField
        let fCity = view.viewWithTag(fieldWithTag["city"]!) as! UITextField
        let fZipcode = view.viewWithTag(fieldWithTag["zipcode"]!) as! UITextField
        let fPhone = view.viewWithTag(fieldWithTag["phone"]!) as! UITextField
        let fAddress = view.viewWithTag(fieldWithTag["address"]!) as! UITextField

        guard fAmdid.text! != "" && fFirstname.text! != "" && fLastname.text! != "" && fDob.text! != "" && fState.text! != "" && fCity.text! != "" && fZipcode.text! != "" && fPhone.text! != "" && fAddress.text != "" else {
            UIAlertView(title: "", message: "One or more fields is left blank. Please fill in all required fields.", delegate: nil, cancelButtonTitle: "OK")
            return
        }
        
        let patient = Patient(internalId: 0, amdid: fAmdid.text!, firstName: fFirstname.text!, lastName: fLastname.text!, dob: fDob.text!, gender: genderSegment.titleForSegment(at: genderSegment.selectedSegmentIndex)!, state: fState.text!, city: fCity.text!, zipcode: fZipcode.text!, phone: fPhone.text!, address: fAddress.text!)
        
        if editedPatient == nil {
            // New record
            print("\(Patient.createNewPatient(patient: patient))")
        } else {
            // Edit mode
            if Patient.updatePatient(patient) <= 0 {
                print("Error saving edited patient.")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
