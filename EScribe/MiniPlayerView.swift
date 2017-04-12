//
//  MiniPlayerView.swift
//  EScribe
//
//  Created by minhnh on 4/3/17.
//
//

import UIKit

protocol MiniPlayerButtonActionDelegate: class {
    func didClickPlayButton(sender: UIButton)
    func didClickPauseButton(sender: UIButton)
    func didClickCloseButton(sender: UIButton)
}

class MiniPlayerView: UIView {

    weak var delegate: MiniPlayerButtonActionDelegate?
    
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var noteTypeLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func playClicked(_ sender: UIButton) {
        delegate?.didClickPlayButton(sender: sender)
    }
    
    @IBAction func pauseClicked(_ sender: UIButton) {
        delegate?.didClickPauseButton(sender: sender)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        AudioRecordHelper.shared.audioPlayer?.currentTime = TimeInterval(sender.value)
    }
    
    @IBAction func closeViewTapped(_ sender: UIButton) {
        delegate?.didClickCloseButton(sender: sender)
    }
}
