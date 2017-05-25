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
    
    // MARK: - Functions
    
    func loadAllPatients() -> [Patient] {
        let patients = Table("patients")
        let internalId = Expression<Int>("internal_id")
        let amdid = Expression<String>("amdid")
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
        patients.order(lastname, firstName)
        
        for patient in try! db.prepare(patients) {
            let patientObj = Patient(internalId: patient[internalId], amdid: patient[amdid], firstName: patient[firstName], lastName: patient[lastname], dob: patient[dob], gender: patient[gender], state: patient[state], city: patient[city], zipcode: patient[zipcode], phone: patient[phone], address: patient[address])
            arrayPatients.append(patientObj)
        }
        
        return arrayPatients
    }
    
    func updatePatient(_ patient: Patient) -> Int {
        let patientTable = Table("patients")
        let kAmdid = Expression<String>("amdid")
        let kFirstName = Expression<String>("firstname")
        let kLastname = Expression<String>("lastname")
        let kAddress = Expression<String>("address")
        let kCity = Expression<String>("city")
        let kState = Expression<String>("us_state")
        let kZipcode = Expression<String>("zipcode")
        let kDob = Expression<String>("dob")
        let kGender = Expression<String>("gender")
        let kPhone = Expression<String>("phone")
        
        let editedPatient = patientTable.filter(kAmdid == patient.amdid)
        return try! db.run(editedPatient.update(kFirstName <- patient.firstName, kLastname <- patient.lastName, kAddress <- patient.address, kCity <- patient.city, kState <- patient.state, kZipcode <- patient.zipcode, kDob <- patient.dob, kGender <- patient.gender, kPhone <- patient.phone))
    }
    
    func loadAllCompletedPatientNotes(patientId: Int) -> [PatientNote] {
        // Patient notes
        let noteId = Expression<Int>("note_id")
        let author = Expression<String>("author")
        let datetime = Expression<String>("datetime")
        
        // Note content
        let parentNoteId = Expression<Int>("big_note_id")
        let storedTypeKey = Expression<Int>("stored_type")
        let voiceRecIndexKey = Expression<Int>("voicerec_index")
        
        // Preparing queries
        let ownedPatientId = Expression<Int>("patient_id")
        let noteContentsTable = Table("note_contents")
        let patientNotesTable = Table("notes").filter(ownedPatientId == patientId && storedTypeKey == 0)
        
        var arrayPatientNotes: [PatientNote] = []
        patientNotesTable.order(noteId)
        
        for patientNote in try! db.prepare(patientNotesTable) {
            let patientNoteObj = PatientNote(bigNoteId: patientNote[noteId], patientId: patientId, author: patientNote[author], datetime: patientNote[datetime])
            patientNoteObj.storedType = patientNote[storedTypeKey]
            patientNoteObj.voiceRecIndex = patientNote[voiceRecIndexKey]
            
            let filterNoteContentsTable = noteContentsTable.filter(parentNoteId == patientNoteObj.bigNoteId)
            let allNoteContents = loadNoteContentsFromResult(result: filterNoteContentsTable)
            
            patientNoteObj.allNoteContents = allNoteContents
            
            arrayPatientNotes.append(patientNoteObj)
        }
        
        return arrayPatientNotes
    }
    
    func loadAllDraftPatientNotes(patientId: Int) -> [PatientNote] {
        // Patient notes
        let noteId = Expression<Int>("note_id")
        let author = Expression<String>("author")
        let datetime = Expression<String>("datetime")
        
        // Note content
        let parentNoteId = Expression<Int>("big_note_id")
        let storedTypeKey = Expression<Int>("stored_type")
        let voiceRecIndexKey = Expression<Int>("voicerec_index")
        
        // Preparing queries
        let ownedPatientId = Expression<Int>("patient_id")
        let noteContentsTable = Table("note_contents")
        let patientNotesTable = Table("notes").filter(ownedPatientId == patientId && storedTypeKey != 0)
        
        var arrayPatientNotes: [PatientNote] = []
        patientNotesTable.order(noteId)
        
        for patientNote in try! db.prepare(patientNotesTable) {
            let patientNoteObj = PatientNote(bigNoteId: patientNote[noteId], patientId: patientId, author: patientNote[author], datetime: patientNote[datetime])
            patientNoteObj.storedType = patientNote[storedTypeKey]
            patientNoteObj.voiceRecIndex = patientNote[voiceRecIndexKey]
            
            let filterNoteContentsTable = noteContentsTable.filter(parentNoteId == patientNoteObj.bigNoteId)
            let allNoteContents = loadNoteContentsFromResult(result: filterNoteContentsTable)
            
            patientNoteObj.allNoteContents = allNoteContents
            
            arrayPatientNotes.append(patientNoteObj)
        }
        
        return arrayPatientNotes
    }
    
    func createNewPatient(amdid: String, firstname: String, lastname: String, dob: String, gender: String, state: String, city: String, zipcode: String, phone: String, address: String) -> Int {
        let patientTable = Table("patients")
        let kAmdid = Expression<String>("amdid")
        let kFirstname = Expression<String>("firstname")
        let kLastname = Expression<String>("lastname")
        let kDob = Expression<String>("dob")
        let kGender = Expression<String>("gender")
        let kState = Expression<String>("us_state")
        let kCity = Expression<String>("city")
        let kZipcode = Expression<String>("zipcode")
        let kPhone = Expression<String>("phone")
        let kAddress = Expression<String>("address")
        
        let resultId = try! db.run(patientTable.insert(kAmdid <- amdid, kFirstname <- firstname, kLastname <- lastname, kDob <- dob, kGender <- gender, kState <- state, kCity <- city, kZipcode <- zipcode, kPhone <- phone, kAddress <- address))
        return Int(resultId)
    }
    
    func deletePatientWithId(_ patientId: Int) {
        // TODO: Resolve the draft note case too
        let arrayPatientNotes = loadAllCompletedPatientNotes(patientId: patientId)
        for note in arrayPatientNotes {
            deletePatientNoteWithId(bigNoteId: note.bigNoteId)
        }
        
        // Delete patient
        let patientTable = Table("patients")
        let kPatientId = Expression<Int>("internal_id")
        
        let deletedPatient = patientTable.filter(kPatientId == patientId)
        try! db.run(deletedPatient.delete())
    }
    
    func createNewPatientNote(patient: Patient, loadFromPatientNoteId: Int) -> Int {
        let patientNoteTable = Table("notes")
        let patientId = Expression<Int>("patient_id")
        let author = Expression<String>("author")
        let datetime = Expression<String>("datetime")
        let kStoredType = Expression<Int>("stored_type")
        let kVoiceRecIndex = Expression<Int>("voicerec_index")
        
        if loadFromPatientNoteId != 0 {
            // Delete the old note and save the new note
            deletePatientNoteWithId(bigNoteId: loadFromPatientNoteId)
        }
        
        if patient.internalId == 0 {
            let returnedId = Patient.createNewPatient(patient: patient)
            let rowId = try! db.run(patientNoteTable.insert(patientId <- returnedId, author <- "Dr Thanh", datetime <- VariousHelper.shared.getDateAndTimeTodayAsString(), kStoredType <- 0, kVoiceRecIndex <- 0))
            return Int(rowId)
        }
        
        // Else do this
        let rowId = try! db.run(patientNoteTable.insert(patientId <- patient.internalId, author <- "Dr Thanh", datetime <- VariousHelper.shared.getDateAndTimeTodayAsString(), kStoredType <- 0, kVoiceRecIndex <- 0))
        return Int(rowId)
    }
    
    func savePatientNoteToDisk(patient: Patient, storedType: Int, voiceRecIndex: Int, loadFromPatientNoteId: Int) -> Int {
        // TODO: Resolve save multiple time case
        let patientNoteTable = Table("notes")
        let patientId = Expression<Int>("patient_id")
        let author = Expression<String>("author")
        let datetime = Expression<String>("datetime")
        let kStoredType = Expression<Int>("stored_type")
        let kVoiceRecIndex = Expression<Int>("voicerec_index")
        
        if loadFromPatientNoteId != 0 {
            // Delete the old note and save the new note
            deletePatientNoteWithId(bigNoteId: loadFromPatientNoteId)
        }
        
        if patient.internalId == 0 {
            let returnedId = Patient.createNewPatient(patient: patient)
            let rowId = try! db.run(patientNoteTable.insert(patientId <- returnedId, author <- "Dr Thanh", datetime <- VariousHelper.shared.getDateAndTimeTodayAsString(), kStoredType <- storedType, kVoiceRecIndex <- voiceRecIndex))
            return Int(rowId)
        }
        
        // Else do this
        let rowId = try! db.run(patientNoteTable.insert(patientId <- patient.internalId, author <- "Dr Thanh", datetime <- VariousHelper.shared.getDateAndTimeTodayAsString(), kStoredType <- storedType, kVoiceRecIndex <- voiceRecIndex))
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
    
    func deletePatientNoteWithId(bigNoteId: Int) {
        let notesTable = Table("notes")
        let notesContentTable = Table("note_contents")
        
        let kBigNoteId = Expression<Int>("note_id")
        let kNoteContentBigNoteId = Expression<Int>("big_note_id")
        
        let deletedNoteContents = notesContentTable.filter(kNoteContentBigNoteId == bigNoteId)
        let deletedBigNotes = notesTable.filter(kBigNoteId == bigNoteId)
        
        try! db.run(deletedNoteContents.delete())
        try! db.run(deletedBigNotes.delete())
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
