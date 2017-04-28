//
//  Appointment.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit
import ObjectMapper

class Appointment: Mappable {
    var apptId = ""
    var apptDate = ""
    var patientId = ""
    var patientName = ""
    var providerName = ""
    var facilityName = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        apptId <- map["ApptID"]
        apptDate <- map["ApptDate"]
        patientId <- map["PatientID"]
        patientName <- map["PatientName"]
        providerName <- map["ProviderName"]
        facilityName <- map["FacilityName"]
    }
}
