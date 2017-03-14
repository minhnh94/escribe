//
//  VariousHelper.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit
import SwiftDate

class VariousHelper: NSObject {
    static let shared = VariousHelper()
    
    override init() {
        // 何もない
    }
    
    func getYearOldFromDateOfBirthString(dob: String) -> Int {
        let dobDate = try! DateInRegion(string: dob, format: .custom("yyyy/MM/dd"))
        let now = DateInRegion()
        
        return now.year - dobDate.year
    }
}
