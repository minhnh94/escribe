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
        //         Uncomment these codes in production
        //        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        // For testing, we load from bundle
        let path = Bundle.main.path(forResource: "escribe", ofType: "db")!
        
        do {
            db = try Connection(path)
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
}
