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
    static let shared = ApiHelper()
    
    override init() {
        
    }
    
    func getListAppointment() {
        // JSON Body
        let body: [String : Any] = [
            "providername": "MOODY,JESSICA"
        ]
        
        // Fetch Request
        Alamofire.request("http://203.205.59.186:8888/getappointment", method: .post, parameters: body)
            .validate(statusCode: 200..<300)
            .responseArray { (response: DataResponse<[Appointment]>) in
                guard let appointmentArray = response.result.value else {
                    print("Error getting appointment data")
                    return
                }
                
                for appointment in appointmentArray {
                    print(appointment.patientName + " " + appointment.apptDate + " " + appointment.providerName)
                }
        }
    }
}
