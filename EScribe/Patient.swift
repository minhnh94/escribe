//
//  Patient.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit

class Patient: NSObject {
    var internalId: Int!
    var amdid: Int!
    var firstName: String!
    var lastName: String!
    var dob: String!
    var gender: String!
    var state: String!
    var city: String!
    var zipcode: String!
    var phone: String!
    var address: String!
    
    init(internalId: Int, amdid: Int,firstName: String, lastName: String, dob: String, gender: String, state: String, city: String, zipcode: String, phone: String, address: String) {
        self.internalId = internalId
        self.amdid = amdid
        self.firstName = firstName
        self.lastName = lastName
        self.dob = dob
        self.gender = gender
        self.state = state
        self.city = city
        self.zipcode = zipcode
        self.phone = phone
        self.address = address
    }
    
    static func allPatients() -> [Patient] {
        return DatabaseHelper.shared.loadAllPatients()
    }
    
    func allNotes() -> [PatientNote] {
        return []
    }
}
