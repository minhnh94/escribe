//
//  AppointmentController.swift
//  EScribe
//
//  Created by minhnh on 4/28/17.
//
//

import UIKit

class AppointmentController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ApiHelper.shared.getListAppointment()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
