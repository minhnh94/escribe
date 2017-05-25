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
    var storedType: Int = 0     // 0: Finished, 1: General draft, 2: Blank note draft
    var voiceRecIndex: Int = 0  // Skip checking if storedType = 0. Value == current index of audio recording file
    
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
    
    static func createNewPatientNote(patient: Patient, loadFromPatientNoteId: Int = 0) -> Int {
        return DatabaseHelper.shared.createNewPatientNote(patient: patient, loadFromPatientNoteId: loadFromPatientNoteId)
    }
    
    static func savePatientNoteToDisk(patient: Patient, storedType: Int, voiceRecIndex: Int, loadFromPatientNoteId: Int = 0) -> Int {
        return DatabaseHelper.shared.savePatientNoteToDisk(patient: patient, storedType: storedType, voiceRecIndex: voiceRecIndex ,loadFromPatientNoteId: loadFromPatientNoteId)
    }
    
    static func deletePatientNoteWithId(bigNoteId: Int) {
        DatabaseHelper.shared.deletePatientNoteWithId(bigNoteId: bigNoteId)
    }
}
