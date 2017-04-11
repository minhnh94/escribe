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
    
    // MARK: - VC stuffs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            present(VariousHelper.shared.getAlertViewAsReturnedValue(message: "One or more fields is left blank. Please fill in all required fields."), animated: true, completion: nil)
            return
        }
        
        let patient = Patient(internalId: 0, amdid: fAmdid.text!, firstName: fFirstname.text!, lastName: fLastname.text!, dob: fDob.text!, gender: genderSegment.titleForSegment(at: genderSegment.selectedSegmentIndex)!, state: fState.text!, city: fCity.text!, zipcode: fZipcode.text!, phone: fPhone.text!, address: fAddress.text!)
        Patient.createNewPatient(patient: patient)
        
        dismiss(animated: true, completion: nil)
    }
}
