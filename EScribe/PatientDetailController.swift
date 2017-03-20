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
    
    var currentPatient: Patient!
    var allNotes: [PatientNote]!
    
    @IBOutlet weak var newNoteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        allNotes = currentPatient.allNotes()
        additionalStyling()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func additionalStyling() {
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

}
