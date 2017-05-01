//
//  AppointmentController.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit

class AppointmentController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var appointmentTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var criteriaSegmentControl: UISegmentedControl!

    var appointmentArray: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ApiHelper.shared.getListAppointment { resultArray in
            self.appointmentArray = resultArray
            self.appointmentTableView.reloadData()
        }
    }
    
    // MARK: - Table view delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
        
        let appointment = appointmentArray[indexPath.row]
        
        cell.appointmentIdLabel.text = appointment.apptId
        cell.datetimeLabel.text = appointment.apptDate
        cell.patientIdLabel.text = appointment.patientId
        cell.patientNameLabel.text = appointment.patientName
        cell.providerNameLabel.text = appointment.providerName
        cell.facilityNameLabel.text = appointment.facilityName
        
        return cell
    }
    
    // MARK: - Actions

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
    }
    
}
