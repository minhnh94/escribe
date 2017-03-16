//
//  PatientListController.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit

class PatientListController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var arrayPatients = DatabaseHelper.shared.loadAllPatients()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view things
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayPatients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientListCell", for: indexPath) as! PatientListCell
        
        let patientObj = arrayPatients[indexPath.row]
        
        cell.patientNameLabel.text = "\(patientObj.firstName!) \(patientObj.lastName!)"
        cell.amdidLabel.text = "\(patientObj.amdid!)"
        cell.internalIdLabel.text = "\(patientObj.internalId!)"
        cell.addressLabel.text = "\(patientObj.address!), \(patientObj.city!), \(patientObj.state!), \(patientObj.zipcode!)"
        cell.dateOfBirthLabel.text = "\(patientObj.dob!)"
        cell.yearOldLabel.text = "(\(VariousHelper.shared.getYearOldFromDateOfBirthString(dob: patientObj.dob)))"
        
        return cell
    }

}
