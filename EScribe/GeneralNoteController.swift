//
//  GeneralNoteController.swift
//  EScribe
//
//  Created by minhnh on 5/12/17.
//
//

import UIKit

class GeneralNoteController: ViewControllerWithDragonSDK {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDictateCommandForTextFields()
    }
    
    private func setupDictateCommandForTextFields() {
        for (key, tag) in NameTagAssociation.nameTagDictionary {
            let inputField = view.viewWithTag(tag)
            inputField?.setVuiConceptName("\(key)")
        }
    }
}
