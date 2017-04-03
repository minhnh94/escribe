//
//  PatientDetailController.swift
//  EScribe
//
//  Created by minhnh on 3/16/17.
//
//

import UIKit
import QuartzCore

class PatientDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, MiniPlayerButtonActionDelegate {
    
    let NewNoteSegue = "ToNewNoteVC"
    
    var currentPatient: Patient!
    var allNotes: [PatientNote]!
    var alreadyLoaded: Bool!
    var filenameToPlay: String = ""
    var isPausing: Bool = false
    
    // Interface
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var yearsOldLabel: UILabel!
    @IBOutlet weak var amdiLabel: UILabel!
    @IBOutlet weak var internalIdLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var newNoteButton: UIButton!
    @IBOutlet weak var notetableView: UITableView!
    
    var playerView: MiniPlayerView?
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        allNotes = currentPatient.allNotes()
        setupInterface()
        additionalStyling()
        
        alreadyLoaded = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if alreadyLoaded == true {
            allNotes = currentPatient.allNotes()
            notetableView.reloadData()
        } else {
            alreadyLoaded = true
        }
    }
    
    private func setupInterface() {
        patientNameLabel.text = "\(currentPatient.firstName!) \(currentPatient.lastName!)"
        amdiLabel.text = "\(currentPatient.amdid!)"
        internalIdLabel.text = "\(currentPatient.internalId!)"
        addressLabel.text = "\(currentPatient.address!), \(currentPatient.city!), \(currentPatient.state!), \(currentPatient.zipcode!)"
        dobLabel.text = "\(currentPatient.dob!)"
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
    }
    
    private func additionalStyling() {
        newNoteButton.layer.borderWidth = 1
        newNoteButton.layer.borderColor = UIColor(red: 0.0/255, green: 122.0/255, blue: 206.0/255, alpha: 1.0).cgColor
        newNoteButton.layer.cornerRadius = 14.0
    }
    
    // MARK: - Actions
    
    @IBAction func recordFileClicked(_ sender: UIButton) {
        let indexPath = notetableView.indexPath(for: sender.superview?.superview as! UITableViewCell)
        filenameToPlay = allNotes[indexPath!.row].allNoteContents.first!.noteId
        isPausing = false
        
        if playerView != nil {
            playerView?.isHidden = false
            updateInterfaceOfMiniPlayer(playerView: playerView!)
        } else {
            playerView = UINib(nibName: "MiniPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? MiniPlayerView
            
            if playerView != nil {
                playerView?.delegate = self
                playerView?.frame = CGRect(x: 0, y: view.frame.size.height - 160 - tabBarController!.tabBar.bounds.size.height, width: view.frame.size.width, height: 160)
                updateInterfaceOfMiniPlayer(playerView: playerView!)
                view.addSubview(playerView!)
            }
        }
        
        notetableView.isUserInteractionEnabled = false
    }
    
    func updateInterfaceOfMiniPlayer(playerView: MiniPlayerView) {
        
    }
    
    func didClickPlayButton(sender: UIButton) {
        if isPausing {
            AudioRecordHelper.shared.resumeAudio()
        } else {
            AudioRecordHelper.shared.playAudio(filename: filenameToPlay)
        }
    }
    
    func didClickPauseButton(sender: UIButton) {
        AudioRecordHelper.shared.pauseAudio()
        isPausing = true
    }
    
    func didClickCloseButton(sender: UIButton) {
        playerView?.isHidden = true
        isPausing = false
        AudioRecordHelper.shared.stopAudio()
        notetableView.isUserInteractionEnabled = true
    }
    
    // MARK: - Table view delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteInPatientDetailCell", for: indexPath) as! NoteInPatientDetailCell
        let note = allNotes[indexPath.row]
        
        cell.dateTimeLabel.text = note.datetime
        cell.noteAuthorLabel.text = note.author
        cell.noteTypesLabel.text = note.joinAllNoteContentTypeIntoString()
        
        return cell
    }

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NewNoteSegue {
            let vc = segue.destination as! NewNoteController
            vc.currentPatient = currentPatient
        }
    }
    
}
