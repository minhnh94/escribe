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
        let docPath = VariousHelper.shared.getDocumentPath().absoluteString
        let enumerator = FileManager.default.enumerator(atPath: docPath)
        let filePaths = enumerator?.allObjects as! [String]
        let txtFilePaths = filePaths.filter{$0.contains(".wav")}
        for txtFilePath in txtFilePaths{
            print(txtFilePath)
            fileArray.append(txtFilePath)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioFileCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
