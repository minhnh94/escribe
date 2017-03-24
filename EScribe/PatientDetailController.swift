//
//  PatientDetailController.swift
//  EScribe
//
//  Created by minhnh on 3/16/17.
//
//

import UIKit
import QuartzCore

class PatientDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let NewNoteSegue = "ToNewNoteVC"
    
    var currentPatient: Patient!
    var allNotes: [PatientNote]!
    
    // Interface
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    @IBOutlet weak var amdiLabel: UILabel!
    @IBOutlet weak var internalIdLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var newNoteButton: UIButton!
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        allNotes = currentPatient.allNotes()
        setupInterface()
        additionalStyling()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupInterface() {
        patientNameLabel.text = "\(currentPatient.firstName!) \(currentPatient.lastName!)"
        amdiLabel.text = "\(currentPatient.amdid!)"
        internalIdLabel.text = "\(currentPatient.internalId!)"
        addressLabel.text = "\(currentPatient.address!), \(currentPatient.city!), \(currentPatient.state!), \(currentPatient.zipcode!)"
        dobLabel.text = "\(currentPatient.dob!)"
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
    }
    
    private func additionalStyling() {
        newNoteButton.layer.borderWidth = 1
        newNoteButton.layer.borderColor = UIColor(red: 0.0/255, green: 122.0/255, blue: 206.0/255, alpha: 1.0).cgColor
        newNoteButton.layer.cornerRadius = 14.0
    }
    
    // MARK: - Table view delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteInPatientDetailCell", for: indexPath) as! NoteInPatientDetailCell
        let note = allNotes[indexPath.row]
        
        cell.dateTimeLabel.text = note.datetime
        cell.noteAuthorLabel.text = note.author
        cell.noteTypesLabel.text = note.joinAllNoteContentTypeIntoString()
        
        return cell
    }

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NewNoteSegue {
            let vc = segue.destination as! NewNoteController
            vc.currentPatient = currentPatient
        }
    }
    
}
