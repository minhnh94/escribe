//
//  LoginController.swift
//  EScribe
//
//  Created by minhnh on 5/25/17.
//
//

import UIKit

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        present(tabBarController, animated: true, completion: nil)
    }
    
}
