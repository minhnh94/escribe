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
    var storedType: Int = 0     // 0: Finished, 1: General draft, 2: Blank note draft
    var voiceRecIndex: Int = 0  // Skip checking if storedType = 0. Value == current index of audio recording file
    
    init(noteId: String, bigNoteId: Int, noteType: String) {
        self.noteId = noteId
        self.bigNoteId = bigNoteId
        self.noteType = noteType
    }
    
    static func createNoteContent(patientNoteId: Int, noteContentId: String, noteType: String = "PCP", content: String, storedType: Int = 0, voiceRecIndex: Int = 0) {
        DatabaseHelper.shared.createNewNoteContent(patientNoteId: patientNoteId, noteContentUid: noteContentId, noteType: noteType, content: content, storedType: storedType, voiceRecIndex: voiceRecIndex)
    }
}
