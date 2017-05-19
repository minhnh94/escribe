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
    let PatientEditSegue = "ToEditPatientVC"
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.isEditing {
            performSegue(withIdentifier: PatientEditSegue, sender: indexPath)
        } else {
            performSegue(withIdentifier: PatientDetailSegue, sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedPatient = arrayPatients[indexPath.row]
            Patient.deletePatient(deletedPatient)
            arrayPatients.remove(at: indexPath.row)
            patientTableView.reloadData()
        }
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Actions
    
    @IBAction func editClicked(_ sender: UIBarButtonItem) {
        if patientTableView.isEditing {
            patientTableView.setEditing(false, animated: true)
            sender.title = "Edit"
        } else {
            patientTableView.setEditing(true, animated: true)
            sender.title = "Done"
        }
    }

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = sender as! IndexPath
        let currentPatient = arrayPatients[indexPath.row]
        
        if segue.identifier == PatientDetailSegue {
            let vc = segue.destination as! PatientDetailController
            vc.currentPatient = currentPatient
        } else if segue.identifier == PatientEditSegue {
            let vc = segue.destination as! NewPatientController
            vc.editedPatient = currentPatient
        }
    }
}
