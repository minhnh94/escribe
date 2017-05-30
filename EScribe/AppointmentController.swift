//
//  AppointmentController.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit

class AppointmentController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var appointmentTableView: UITableView!
    @IBOutlet weak var datetimeTextField: UITextField!
    @IBOutlet weak var totalAppointmentsLabel: UILabel!
    var picker = UIDatePicker()
    
    var appointmentArray: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadDataFromServer(date: Date())
        datetimeTextField.text = VariousHelper.shared.getDateTodayAsString()
        setupPicker()
    }
    
    private func setupPicker() {
        picker.datePickerMode = .date
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolbar.tintColor = UIColor.gray
        let barBtnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDatePicker))
        toolbar.items = [barBtnDone]
        
        datetimeTextField.inputView = picker
        datetimeTextField.inputAccessoryView = toolbar
    }

    func handleDatePicker() {
        datetimeTextField.text = VariousHelper.shared.getADateAsString(date: picker.date)
        
        loadDataFromServer(date: picker.date)
        
        datetimeTextField.resignFirstResponder()
    }
    
    private func loadDataFromServer(date: Date) {
        let apiHelper = ApiHelper()
        
        apiHelper.startDate = VariousHelper.shared.getADateAsString(date: date)
        apiHelper.endDate = VariousHelper.shared.getADateAsString(date: date)
        
        apiHelper.getListAppointment { resultArray in
            self.appointmentArray = resultArray
            self.appointmentTableView.reloadData()
            self.totalAppointmentsLabel.text = "\(self.appointmentArray.count)"
        }
    }
    
    // MARK: - Date picker delegate
    

    
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
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToNewNoteVC" {
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
