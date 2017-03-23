//
//  NewNoteController.swift
//  EScribe
//
//  Created by minhnh on 3/20/17.
//
//

import UIKit

class NewNoteController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let newNoteTypeArray = ["PCP / Cardiology"]     // More will be added on demand
    var currentPatient: Patient!
    
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupInterface() {
        patientNameLabel.text = currentPatient.firstName + " " + currentPatient.lastName
        dobLabel.text = currentPatient.dob
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
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
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToInputNoteVC" {
            let vc = segue.destination as! ViewController
            vc.title = "PCP / Cardiology"
            vc.currentPatient = currentPatient
        }
    }
}