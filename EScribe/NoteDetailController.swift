//
//  NoteDetailController.swift
//  EScribe
//
//  Created by minhnh on 4/11/17.
//
//

import UIKit

class NoteDetailController: UIViewController {

    var currentPatient: Patient!
    var noteDetail: String!
    
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    @IBOutlet weak var noteDetailTextView: UITextView!
    
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
        patientNameLabel.text = "\(currentPatient.firstName!) \(currentPatient.lastName!)"
        dobLabel.text = "\(currentPatient.dob!)"
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
        
        parseResult()
    }
    
    private func parseResult() {
        noteDetailTextView.text = VariousHelper.shared.convertXMLStringToReadableString(xmlString: noteDetail)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
