//
//  VariousHelper.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit
import SwiftDate
import AEXML

class VariousHelper: NSObject {
    static let shared = VariousHelper()
    
    override init() {
        // Just a placeholder
    }
    
    func getADateAsString(date: Date) -> String {
        return DateInRegion(absoluteDate: date).string(custom: "yyyy-MM-dd")
    }
    
    func getDateTodayAsString() -> String {
        return DateInRegion().string(custom: "yyyy-MM-dd")
    }
    
    func getTodayAsFullString() -> String {
        let date = DateInRegion()
        return "\(date.year)\(date.shortMonthName)\(date.day)\(date.weekdayName)\(date.string(custom: "HH-mm-ss"))"
    }
    
    func getDateAndTimeTodayAsString() -> String {
        return DateInRegion().string(custom: "yyyy-MM-dd HH:mm:ss")
    }
    
    func getDateAfterAWeekFromTodayAsString() -> String {
        let date = DateInRegion() + 1.weeks
        return date.string(custom: "yyyy-MM-dd")
    }
    
    func getDateAfterAMonthFromTodayAsString() -> String {
        let date = DateInRegion() + 1.months
        return date.string(custom: "yyyy-MM-dd")
    }
    
    func getYearOldFromDateOfBirthString(dob: String) -> Int {
        let dobDate = try! DateInRegion(string: dob, format: .custom("yyyy-MM-dd"))
        let now = DateInRegion()
        
        return now.year - dobDate.year
    }
    
    func getTimeStringFromDurationInSecond(duration: Int) -> String {
        let c: [Calendar.Component: Int] = [.second: duration]
        let date = try! DateInRegion(components: c)
        return date.string(custom: "HH:mm:ss")
    }
    
    func getDocumentPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirect = paths[0]
        
        return docDirect
    }
    
    func savePhysicianName(name: String) {
        UserDefaults.standard.set(name.capitalized, forKey: "loginName")
    }
    
    func loadCurrentPhysicianName() -> String {
        return UserDefaults.standard.value(forKey: "loginName") as! String
    }
    
    func convertXMLStringToReadableString(xmlString: String) -> String {
        var result = ""
        
        do {
            let xml = try AEXMLDocument(xml: xmlString)
            for child in xml.root.children {
                result = result + "*\(child.name.replacingOccurrences(of: "_", with: " ").capitalized)\n"
                result = result + "\(child.string)\n\n"
            }
        } catch let error {
            print("Cannot parse xml: \(error.localizedDescription)")
        }
        
        return result
    }
    
    func convertXMLStringToDictionary(xmlString: String) -> [String: String] {
        var result: [String: String] = [:]
        
        do {
            let xml = try AEXMLDocument(xml: xmlString)
            for child in xml.root.children {
                let key = child.name.replacingOccurrences(of: "_", with: " ")
                result[key] = child.string
            }
        } catch let error {
            print("Cannot parse xml: \(error.localizedDescription)")
        }
        
        return result
    }
}
