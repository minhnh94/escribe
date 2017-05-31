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
    
    func sendAudioFileToNuance(completion: @escaping (_ result: Any) -> Void) {
        let headers = [
            "Accept":"application/xml",
            "Content-Type":"audio/x-wav;codec=pcm;bit=16;rate=16000",
            "Accept-Topic":"Dictation",
            "Accept-Language":"ENUS",
            "X-Dictation-Nbestlistsize":"1",
            ]
        
        let audioUrl = Bundle.main.url(forResource: "audio_16k16bit", withExtension: "wav")
        Alamofire.upload(audioUrl!, to: "https://dictation.nuancemobility.net:443/NMDPAsrCmdServlet/dictation?appId=NMDPTRIAL_minhnh_da_gmail_com20170206055537&appKey=9b35dcfe5ce50ab03bd366d929f2c775cedc1b88ab44b13340625481bc104357461f55a20460534033b9195cabe1d17abdec026930b39c7115f0f2d101352847&id=C4461956B60B", method: .post, headers: headers).responseString { (data) in
            print(data)
        }
    }
}
