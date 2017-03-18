//
//  BigNote.swift
//  EScribe
//
//  Created by minhnh on 3/17/17.
//
//

import UIKit

class PatientNote: NSObject {
    var bigNoteId: Int!
    var patientId: Int!
    var author: String!
    var allNoteContents: [NoteContent] = []
    
    init(bigNoteId: Int, patientId: Int, author: String) {
        self.bigNoteId = bigNoteId
        self.patientId = patientId
        self.author = author
    }
}
