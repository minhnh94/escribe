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
    
    func getDocumentPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirect = paths[0]
        
        return docDirect
    }
    
    func getAlertView(message: String) {
        let vc = UIAlertController(title: "", message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(vc, animated: true, completion: nil)
    }
}
