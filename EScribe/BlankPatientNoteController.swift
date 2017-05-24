//
//  BlankPatientNoteController.swift
//  EScribe
//
//  Created by minhnh on 5/23/17.
//
//

import UIKit

class BlankPatientNoteController: ViewControllerWithDragonSDK {

    @IBOutlet weak var blankNoteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagDictionaryChoice = 1
        
        setupDictateCommandForTextFields()
        
        blankNoteTextView.layer.borderWidth = 3
        blankNoteTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func setupDictateCommandForTextFields() {
        for (key, tag) in NameTagAssociation.blankTagDictionary {
            let inputField = view.viewWithTag(tag) as! UITextView
            inputField.setVuiConceptName("\(key)")
        }
    }
}
