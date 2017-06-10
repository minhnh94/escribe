//
//  PatientDetailController.swift
//  EScribe
//
//  Created by minhnh on 3/16/17.
//
//

import UIKit
import QuartzCore

class PatientDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, MiniPlayerButtonActionDelegate, NowPlayingUpdateDelegate {
    
    let NewNoteSegue = "ToNewNoteVC"
    let NoteDetailSegue = "ToNoteDetailController"
    
    var currentPatient: Patient!
    var allNotes: [PatientNote]!
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
    @IBOutlet weak var showNoteSegment: UISegmentedControl!
    
    var playerView: MiniPlayerView?
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInterface()
        additionalStyling()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AudioRecordHelper.shared.delegate = self
        
        if showNoteSegment.selectedSegmentIndex == 0 {
            allNotes = currentPatient.allCompletedNotes()
        } else {
            allNotes = currentPatient.allDraftNotes()
        }
        
        notetableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioRecordHelper.shared.delegate = nil
    }
    
    private func setupInterface() {
        patientNameLabel.text = "\(currentPatient.firstName!) \(currentPatient.lastName!)"
        amdiLabel.text = "\(currentPatient.amdid!)"
        internalIdLabel.text = "\(currentPatient.internalId!)"
        addressLabel.text = "\(currentPatient.address!), \(currentPatient.city!), \(currentPatient.state!), \(currentPatient.zipcode!)"
        dobLabel.text = "\(currentPatient.dob!)"
        yearsOldLabel.text = "(\(currentPatient.getYearsOld()))"
        showNoteSegment.selectedSegmentIndex = 0
    }
    
    private func additionalStyling() {
        newNoteButton.layer.borderWidth = 1
        newNoteButton.layer.borderColor = UIColor(red: 0.0/255, green: 122.0/255, blue: 206.0/255, alpha: 1.0).cgColor
        newNoteButton.layer.cornerRadius = 14.0
    }
    
    // MARK: - Actions
    
    @IBAction func newNoteClicked(_ sender: UIButton) {
        performSegue(withIdentifier: NewNoteSegue, sender: nil)
    }
    
    @IBAction func showNoteSegmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // Show completed
            allNotes = currentPatient.allCompletedNotes()
        } else {
            // Show draft
            allNotes = currentPatient.allDraftNotes()
        }
        
        notetableView.reloadData()
    }
    
    @IBAction func recordFileClicked(_ sender: UIButton) {
        let indexPath = notetableView.indexPath(for: sender.superview?.superview as! UITableViewCell)
        filenameToPlay = allNotes[indexPath!.row].allNoteContents.first!.noteId
        isPausing = false
        
        playerView = UINib(nibName: "MiniPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? MiniPlayerView
        
        if playerView != nil {
            playerView?.delegate = self
            playerView?.frame = CGRect(x: 0, y: view.frame.size.height - 160 - tabBarController!.tabBar.bounds.size.height, width: view.frame.size.width, height: 160)
            updateInterfaceOfMiniPlayer(playerView: playerView!, data: allNotes[indexPath!.row])
            view.addSubview(playerView!)
        }
        
        notetableView.isUserInteractionEnabled = false
    }
    
    @IBAction func trashFileClicked(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Deleting patient note", message: "You are going to delete the selected patient note. Are you sure?", preferredStyle: .alert)
        let actionDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            let indexPath = self.notetableView.indexPath(for: sender.superview?.superview as! UITableViewCell)
            let noteId = self.allNotes[indexPath!.row].bigNoteId!
            
            PatientNote.deletePatientNoteWithId(bigNoteId: noteId)
            let storedFileId = self.allNotes[indexPath!.row].allNoteContents.first!.noteId
            do {
                try FileManager.default.removeItem(at: VariousHelper.shared.getDocumentPath().appendingPathComponent("\(storedFileId!).txt"))
                try FileManager.default.removeItem(at: VariousHelper.shared.getDocumentPath().appendingPathComponent("\(storedFileId!).m4a"))
            } catch let error {
                print("Cannot delete file: \(error.localizedDescription)")
            }
            
            if self.showNoteSegment.selectedSegmentIndex == 0 {
                self.allNotes = self.currentPatient.allCompletedNotes()
            } else {
                self.allNotes = self.currentPatient.allDraftNotes()
            }
            self.notetableView.reloadData()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(actionDelete)
        alertVC.addAction(actionCancel)
        
        present(alertVC, animated: true, completion: nil)
        
    }

    @IBAction func uploadFileBtnClicked(_ sender: UIButton) {
        let indexPath = notetableView.indexPath(for: sender.superview?.superview as! UITableViewCell)
        filenameToPlay = allNotes[indexPath!.row].allNoteContents.first!.noteId
        
        let alertVC = UIAlertController(title: "Uploading file", message: "Select the file type you want to upload. Then choose the \"Copy to Drive\" action in the presented view. You must have the Google Drive application installed for the \"Copy to Drive\" action to show", preferredStyle: .actionSheet)
        let actionUploadText = UIAlertAction(title: "Upload patient note", style: .default) { _ in
            let urlFile = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(self.filenameToPlay).txt")
            self.uploadFileViaActivityVC(url: urlFile)
        }
        let actionUploadAudio = UIAlertAction(title: "Upload audio file", style: .default) { _ in
            let urlAudio = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(self.filenameToPlay).m4a")
            self.uploadFileViaActivityVC(url: urlAudio)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(actionUploadText)
        alertVC.addAction(actionUploadAudio)
        alertVC.addAction(actionCancel)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func uploadFileViaActivityVC(url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            avc.excludedActivityTypes = [.addToReadingList, .saveToCameraRoll, .airDrop, .postToTwitter, .copyToPasteboard, .postToFacebook, .message, .mail, .print, .assignToContact, UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"), UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            present(avc, animated: true, completion: nil)
        }
    }
    
    func updateInterfaceOfMiniPlayer(playerView: MiniPlayerView, data: PatientNote) {
        AudioRecordHelper.shared.setupAudio(filename: "\(filenameToPlay).m4a")
        playerView.datetimeLabel.text = data.datetime
        playerView.noteTypeLabel.text = data.allNoteContents.first!.noteType
        playerView.slider.value = 0
        playerView.doctorLabel.text = VariousHelper.shared.loadCurrentPhysicianName()
    }
    
    func didClickPlayButton(sender: UIButton) {
        if isPausing {
            AudioRecordHelper.shared.resumeAudio()
        } else {
            AudioRecordHelper.shared.playAudio()
        }
    }
    
    func didClickPauseButton(sender: UIButton) {
        AudioRecordHelper.shared.pauseAudio()
        isPausing = true
    }
    
    func didClickCloseButton(sender: UIButton) {
        playerView?.removeFromSuperview()
        playerView = nil
        isPausing = false
        AudioRecordHelper.shared.stopAudio()
        notetableView.isUserInteractionEnabled = true
    }
    
    // MARK: - Audio helper delegate
    
    func playerDidGetDuration(duration: TimeInterval) {
        playerView?.slider.maximumValue = Float(duration)
        playerView?.durationLabel.text = VariousHelper.shared.getTimeStringFromDurationInSecond(duration: Int(duration))
    }
    
    func playerDidUpdateTime(timeInterval: TimeInterval) {
        playerView?.slider.value = Float(timeInterval)
    }
    
    func didUpdateSoundDecibel(value: Float) {
        // Fuck swift no optional, leave this blank
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
        
        let storedAudioFileId = note.allNoteContents.first!.noteId!
        if FileManager.default.fileExists(atPath: VariousHelper.shared.getDocumentPath().appendingPathComponent("\(storedAudioFileId).m4a").path) {
            cell.playAudioButton.setImage(#imageLiteral(resourceName: "ico-play"), for: .normal)
            cell.playAudioButton.isUserInteractionEnabled = true
        } else {
            cell.playAudioButton.setImage(#imageLiteral(resourceName: "ico-play-disabled"), for: .normal)
            cell.playAudioButton.isUserInteractionEnabled = false
        }
        
        if showNoteSegment.selectedSegmentIndex == 0 {
            cell.uploadButton.isUserInteractionEnabled = true
            cell.uploadButton.setImage(#imageLiteral(resourceName: "ico_upload"), for: .normal)
        } else {
            cell.uploadButton.isUserInteractionEnabled = false
            cell.uploadButton.setImage(#imageLiteral(resourceName: "ico_upload_disabled"), for: .normal)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if showNoteSegment.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: NoteDetailSegue, sender: indexPath)
        } else {
            performSegue(withIdentifier: NewNoteSegue, sender: indexPath)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == NewNoteSegue {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! NewNoteController
            vc.currentPatient = currentPatient
            
            if sender != nil {
                let indexPath = sender as! IndexPath
                let editedPatientNote = allNotes[indexPath.row]
                vc.toBeEditedPatientNote = editedPatientNote
            }
            
        } else if segue.identifier == NoteDetailSegue {
            let vc = segue.destination as! NoteDetailController
            vc.currentPatient = currentPatient
            let indexPath = sender as! IndexPath
            vc.noteDetail = allNotes[indexPath.row].allNoteContents.first!.content
        }
    }
    
}
