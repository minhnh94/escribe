//
//  LoginController.swift
//  EScribe
//
//  Created by minhnh on 5/25/17.
//
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        guard usernameTxtField.text != "" && passwordTxtField.text != "" else {
            let alertVC = UIAlertView(title: "Login error", message: "Login or password field left blank.", delegate: nil, cancelButtonTitle: "OK")
            alertVC.show()
            
            return
        }
        
        VariousHelper.shared.savePhysicianName(name: usernameTxtField.text!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        present(tabBarController, animated: true, completion: nil)
    }
    
}
