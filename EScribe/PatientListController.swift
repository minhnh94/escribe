//
//  PatientListController.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit

class PatientListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    let PatientDetailSegue = "ToPatientDetailVC"
    var arrayPatients = Patient.allPatients()
    
    @IBOutlet weak var patientTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arrayPatients = Patient.allPatients()
        patientTableView.reloadData()
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
        cell.yearOldLabel.text = "(\(patientObj.getYearsOld()))"
        
        return cell
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PatientDetailSegue {
            let indexPath = patientTableView.indexPath(for: sender as! UITableViewCell)
            let currentPatient = arrayPatients[indexPath!.row]
            
            let vc = segue.destination as! PatientDetailController
            vc.currentPatient = currentPatient
        }
    }
}
