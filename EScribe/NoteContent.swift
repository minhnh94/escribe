//
//  PatientNote.swift
//  EScribe
//
//  Created by minhnh on 3/17/17.
//
//

import UIKit

class NoteContent: NSObject {
    var noteId: String!
    var bigNoteId: Int!
    var noteType: String!
    var content: String = ""
    
    init(noteId: String, bigNoteId: Int, noteType: String) {
        self.noteId = noteId
        self.bigNoteId = bigNoteId
        self.noteType = noteType
    }
    
    static func createNoteContent(patientNoteId: Int, noteContentId: String, noteType: String = "PCP", content: String) {
        DatabaseHelper.shared.createNewNoteContent(patientNoteId: patientNoteId, noteContentUid: noteContentId, noteType: noteType, content: content)
    }
}
