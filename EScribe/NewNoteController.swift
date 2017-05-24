//
//  NewNoteController.swift
//  EScribe
//
//  Created by minhnh on 3/20/17.
//
//

import UIKit

class NewNoteController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let newNoteTypeArray = ["General", "PCP", "Cardiology", "Blank note", "Continue editing"]     // More will be added on demand
    var currentPatient: Patient!
    
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    @IBOutlet weak var noteTypeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupInterface() {
        patientNameLabel.text = currentPatient.firstName + " " + currentPatient.lastName
        dobLabel.text = currentPatient.dob
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
    }
    
    // MARK: - Actions
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newNoteTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewNoteTypeCell", for: indexPath)
        
        cell.textLabel?.text = newNoteTypeArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == newNoteTypeArray.count - 2) {
            performSegue(withIdentifier: "ToBlankNoteVC", sender: indexPath)
        } else {
            performSegue(withIdentifier: "ToInputNoteVC", sender: indexPath)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = sender as! IndexPath
        
        let vc = segue.destination as! ViewControllerWithDragonSDK
        vc.title = newNoteTypeArray[indexPath.row]
        vc.currentPatient = currentPatient
        
        if segue.identifier == "ToInputNoteVC" {
        
        } else if segue.identifier == "ToBlankNoteVC" {
            
        }
    }
}
