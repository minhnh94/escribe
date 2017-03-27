//
//  DatabaseHelper.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit
import SQLite

class DatabaseHelper: NSObject {
    static let shared = DatabaseHelper()
    
    var db: Connection!
    
    override init() {
        let docDir = VariousHelper.shared.getDocumentPath().appendingPathComponent("escribe.db")
        // For testing, we load from bundle
        
        if !FileManager.default.fileExists(atPath: docDir.path) {
            let path = Bundle.main.path(forResource: "escribe", ofType: "db")!
            try! FileManager.default.copyItem(atPath: path, toPath: docDir.path)
        }
        
        do {
            db = try Connection(docDir.path)
        } catch let error {
            print("Error loading database: \(error)")
        }
    }
    
    func loadAllPatients() -> [Patient] {
        let patients = Table("patients")
        let internalId = Expression<Int>("internal_id")
        let amdid = Expression<Int>("amdid")
        let firstName = Expression<String>("firstname")
        let lastname = Expression<String>("lastname")
        let address = Expression<String>("address")
        let city = Expression<String>("city")
        let state = Expression<String>("us_state")
        let zipcode = Expression<String>("zipcode")
        let dob = Expression<String>("dob")
        let gender = Expression<String>("gender")
        let phone = Expression<String>("phone")
        
        var arrayPatients: [Patient] = []
        
        for patient in try! db.prepare(patients) {
            let patientObj = Patient(internalId: patient[internalId], amdid: patient[amdid], firstName: patient[firstName], lastName: patient[lastname], dob: patient[dob], gender: patient[gender], state: patient[state], city: patient[city], zipcode: patient[zipcode], phone: patient[phone], address: patient[address])
            arrayPatients.append(patientObj)
        }
        
        return arrayPatients
    }
    
    func loadAllPatientNotes(patientId: Int) -> [PatientNote] {
        // Patient notes
        let noteId = Expression<Int>("note_id")
        let author = Expression<String>("author")
        let datetime = Expression<String>("datetime")
        
        // Note content
        let parentNoteId = Expression<Int>("big_note_id")
        
        // Preparing queries
        let ownedPatientId = Expression<Int>("patient_id")
        let noteContentsTable = Table("note_contents")
        let patientNotesTable = Table("notes").filter(ownedPatientId == patientId)
        
        var arrayPatientNotes: [PatientNote] = []
        
        for patientNote in try! db.prepare(patientNotesTable) {
            let patientNoteObj = PatientNote(bigNoteId: patientNote[noteId], patientId: patientId, author: patientNote[author], datetime: patientNote[datetime])
            
            let filterNoteContentsTable = noteContentsTable.filter(parentNoteId == patientNoteObj.bigNoteId)
            let allNoteContents = loadNoteContentsFromResult(result: filterNoteContentsTable)
            
            patientNoteObj.allNoteContents = allNoteContents
            
            arrayPatientNotes.append(patientNoteObj)
        }
        
        return arrayPatientNotes
    }
    
    func createNewPatientNote(patient: Patient) -> Int {
        let patientNoteTable = Table("notes")
        let patientId = Expression<Int>("patient_id")
        let author = Expression<String>("author")
        let datetime = Expression<String>("datetime")
        let rowId = try! db.run(patientNoteTable.insert(patientId <- patient.internalId, author <- "Dr Thanh", datetime <- "2017/01/06-21:55:33"))
        
        return Int(rowId)
    }
    
    func createNewNoteContent(patientNoteId: Int, noteContentUid: String, noteType: String, content: String) {
        let noteContentTable = Table("note_contents")
        let noteContentId = Expression<String>("note_content_id")
        let patientNoteKeyId = Expression<Int>("big_note_id")
        let noteTypeKey = Expression<String>("note_type")
        let contentKey = Expression<String>("content")
        
        try! db.run(noteContentTable.insert(noteContentId <- noteContentUid, patientNoteKeyId <- patientNoteId, noteTypeKey <- noteType, contentKey <- content))
    }
    
    // MARK: - Privates
    
    private func loadNoteContentsFromResult(result: Table) -> [NoteContent] {
        var arrayResult: [NoteContent] = []
        
        // Note content
        let patientNoteId = Expression<Int>("big_note_id")
        let noteContentId = Expression<String>("note_content_id")
        let noteType = Expression<String>("note_type")
        let noteContentString = Expression<String>("content")
        
        for noteContent in try! db.prepare(result) {
            let noteContentObj = NoteContent(noteId: noteContent[noteContentId], bigNoteId: noteContent[patientNoteId], noteType: noteContent[noteType])
            noteContentObj.content = noteContent[noteContentString]
            arrayResult.append(noteContentObj)
        }
        
        return arrayResult
    }
}
