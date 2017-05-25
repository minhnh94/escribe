//
//  NoteInPatientDetailCell.swift
//  EScribe
//
//  Created by minhnh on 3/17/17.
//
//

import UIKit

class NoteInPatientDetailCell: UITableViewCell {

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var noteTypesLabel: UILabel!
    @IBOutlet weak var noteAuthorLabel: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
