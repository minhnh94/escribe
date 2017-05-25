//
//  ApiHelper.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class ApiHelper: NSObject {
    private let Host = "http://203.205.59.186:8888/"
    
    private let GetAppointmentAPI = "getappointment"
    
    private let kStartDate = "startdate"
    private let kEndDate = "enddate"
    private let kPatientId = "patientid"
    private let kPatientName = "patientname"
    private let kProviderName = "providername"
    
    var startDate: String?
    var endDate: String?
    var patientId: String?
    var patientName: String?
    var providerName: String?
    
    override init() {
        
    }
    
    func getListAppointment(completion: @escaping (_ result: [Appointment]) -> Void) {
        // Default: Get this week's appointments
        var body: [String : Any] = [:]
        
        if let uStartDate = startDate {
            body[kStartDate] = uStartDate
        }
        if let uEndDate = endDate {
            body[kEndDate] = uEndDate
        }
        if let uPatientId = patientId {
            body[kPatientId] = uPatientId
        }
        if let uPatientName = patientName {
            body[kPatientName] = uPatientName
        }
        if let uProviderName = providerName {
            body[kProviderName] = uProviderName
        }
        
        // Fetch Request
        Alamofire.request(Host + GetAppointmentAPI, method: .post, parameters: body)
            .validate(statusCode: 200..<300)
            .responseArray { (response: DataResponse<[Appointment]>) in
                guard let appointmentArray = response.result.value else {
                    print("Error getting appointment data: \(String(describing: response.data))")
                    completion([])
                    return
                }
                
                completion(appointmentArray.sorted(by: { (a1, a2) -> Bool in
                    a1.apptDate < a2.apptDate
                }))
        }
    }
}
