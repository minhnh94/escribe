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
    var datetime: String!
    var allNoteContents: [NoteContent] = []
    
    init(bigNoteId: Int, patientId: Int, author: String, datetime: String) {
        self.bigNoteId = bigNoteId
        self.patientId = patientId
        self.author = author
        self.datetime = datetime
    }
    
    func joinAllNoteContentTypeIntoString() -> String {
        var result = ""
        
        for noteContent in allNoteContents {
            result += noteContent.noteType
            if allNoteContents.last != noteContent {
                result += ", "
            }
        }
        
        return result
    }
    
    static func createNewPatientNote(patient: Patient) -> Int {
        return DatabaseHelper.shared.createNewPatientNote(patient: patient)
    }
    
    static func deletePatientNoteWithId(bigNoteId: Int) {
        DatabaseHelper.shared.deletePatientNoteWithId(bigNoteId: bigNoteId)
    }
}
