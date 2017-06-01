//
//  ParseAudioController.swift
//  EScribe
//
//  Created by minhnh on 5/31/17.
//
//

import UIKit

class ParseAudioController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var fileArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let docPath = VariousHelper.shared.getDocumentPath().path
        let filemanager:FileManager = FileManager()
        print(NSHomeDirectory())
        let files = filemanager.enumerator(atPath: docPath)
        while let file = files?.nextObject() {
            let fileName = file as! String
            if fileName.hasSuffix(".wav") {
                fileArray.append(fileName)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioFileCell", for: indexPath)
        
        cell.textLabel?.text = fileArray[indexPath.row]
        cell.textLabel?.textColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:206.0/255.0, alpha:255.0/255.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
