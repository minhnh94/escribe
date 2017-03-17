//
//  PatientNote.swift
//  EScribe
//
//  Created by minhnh on 3/17/17.
//
//

import UIKit

class NoteContent: NSObject {
    var noteId: Int!
    var bigNoteId: Int!
    var noteType: String!
    var content: String = ""
    
    init(noteId: Int, bigNoteId: Int, noteType: String) {
        self.noteId = noteId
        self.bigNoteId = bigNoteId
        self.noteType = noteType
    }
}
