//
//  StreamingInputController.swift
//  EScribe
//
//  Created by minhnh on 6/10/17.
//
//

import UIKit

protocol SubmitAudioDelegate: class {
    func didSubmitAudioFileWithPath(_ path: String)
}

class StreamingInputController: UIViewController, NowPlayingUpdateDelegate, MiniPlayerButtonActionDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var decibelMeasureBar: UIProgressView!
    
    var isRecording = 0
    var isPausing: Bool = false
    weak var delegate: SubmitAudioDelegate?
    var playerView: MiniPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AudioRecordHelper.shared.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioRecordHelper.shared.delegate = nil
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func recordClicked(_ sender: UIButton) {
        if isRecording == 0 {
            print("Recording started...")
            isRecording = 1
            AudioRecordHelper.shared.recordToWavFormat(filename: "StreamInput")
            recordButton.setImage(#imageLiteral(resourceName: "stop_mic"), for: .normal)
        } else {
            print("Recording stopped!")
            isRecording = 0
            AudioRecordHelper.shared.stopRecording()
            recordButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        }
    }
    
    @IBAction func playClicked(_ sender: UIButton) {
        let path = VariousHelper.shared.getDocumentPath().appendingPathComponent("StreamInput.wav").path
        if FileManager.default.fileExists(atPath: path) {
            playerView = UINib(nibName: "MiniPlayerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? MiniPlayerView
            
            if playerView != nil {
                playerView?.delegate = self
                playerView?.frame = CGRect(x: 0, y: view.frame.size.height - 160, width: view.frame.size.width, height: 160)
                updateInterfaceOfMiniPlayer(playerView: playerView!)
                view.addSubview(playerView!)
            }
        } else {
            UIAlertView(title: "", message: "No record file to play. Maybe you haven't started recording yet.", delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    func updateInterfaceOfMiniPlayer(playerView: MiniPlayerView) {
        AudioRecordHelper.shared.setupAudio(filename: "StreamInput.wav")
        playerView.datetimeLabel.text = ""
        playerView.noteTypeLabel.text = ""
        playerView.slider.value = 0
        playerView.doctorLabel.text = ""
    }

    @IBAction func submitClicked(_ sender: UIButton) {
        let path = VariousHelper.shared.getDocumentPath().appendingPathComponent("StreamInput.wav").path
        if FileManager.default.fileExists(atPath: path) {
            delegate?.didSubmitAudioFileWithPath(path)
        } else {
            delegate?.didSubmitAudioFileWithPath("")
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Player delegate
    
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
    }
    
    // Audio playing delegate
    
    func playerDidGetDuration(duration: TimeInterval) {
        playerView?.slider.maximumValue = Float(duration)
        playerView?.durationLabel.text = VariousHelper.shared.getTimeStringFromDurationInSecond(duration: Int(duration))
    }
    
    func playerDidUpdateTime(timeInterval: TimeInterval) {
        playerView?.slider.value = Float(timeInterval)
    }
    
    func didUpdateSoundDecibel(value: Float) {
        decibelMeasureBar.progress = -1 / value
    }
    
}
