//
//  AppointmentController.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit

class AppointmentController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, DoneButtonClickedDelegate {
    
    @IBOutlet weak var appointmentTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var totalAppointmentsLabel: UILabel!
    
    var timeRangeSetting = 1   // 0: Today, 1: Week, 2: Month
    var stringFilterSetting = 1     // 0: Patient id, 1: Patient name, 2: Provider name
    var appointmentArray: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDataFromServer()
    }
    
    private func loadDataFromServer() {
        let apiHelper = ApiHelper()
        
        switch timeRangeSetting {
        case 0:
            apiHelper.startDate = VariousHelper.shared.getDateTodayAsString()
            apiHelper.endDate = VariousHelper.shared.getDateTodayAsString()
            break
        case 1:
            apiHelper.startDate = VariousHelper.shared.getDateTodayAsString()
            apiHelper.endDate = VariousHelper.shared.getDateAfterAWeekFromTodayAsString()
            break
        case 2:
            apiHelper.startDate = VariousHelper.shared.getDateTodayAsString()
            apiHelper.endDate = VariousHelper.shared.getDateAfterAMonthFromTodayAsString()
            break
        default:
            apiHelper.startDate = VariousHelper.shared.getDateTodayAsString()
            apiHelper.endDate = VariousHelper.shared.getDateAfterAWeekFromTodayAsString()
            break
        }
        
        switch stringFilterSetting {
        case 0:
            apiHelper.patientId = searchBar.text
            break
        case 1:
            apiHelper.patientName = searchBar.text
            break
        case 2:
            apiHelper.providerName = searchBar.text
            break
        default:
            break
        }
        
        apiHelper.getListAppointment { resultArray in
            self.appointmentArray = resultArray
            self.appointmentTableView.reloadData()
            self.totalAppointmentsLabel.text = "\(self.appointmentArray.count)"
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
        
        return cell
    }
    
    // MARK: - Search bar delegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        loadDataFromServer()
    }
    
    // MARK: - Filter controller delegate
    
    func doneButtonDidClicked(stringFilter: Int, timeRangeFilter: Int) {
        stringFilterSetting = stringFilter
        timeRangeSetting = timeRangeFilter
        loadDataFromServer()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToTimeRangeFilterController" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! TimeSelectController
            vc.timeRangeSetting = timeRangeSetting
            vc.doneBtnDelegate = self
        } else if segue.identifier == "ToNewNoteVC" {
            let indexPath = appointmentTableView.indexPath(for: sender as! UITableViewCell)
            let appointmentData = appointmentArray[indexPath!.row]
            
            // This tedious piece of shit just for separating name
            let firstName = appointmentData.patientName.components(separatedBy: ",").first!.capitalized
            let lastName = appointmentData.patientName.components(separatedBy: ",").last!.capitalized
            
            let patient = Patient(internalId: 0, amdid: appointmentData.patientId, firstName: firstName, lastName: lastName, dob: "", gender: "", state: "", city: "", zipcode: "", phone: "", address: "")
            
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! NewNoteController
            vc.currentPatient = patient
        }
    }
}
