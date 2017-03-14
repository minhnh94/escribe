//
//  PatientListCell.swift
//  EScribe
//
//  Created by minhnh on 3/14/17.
//
//

import UIKit

class PatientListCell: UITableViewCell {

    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var amdidLabel: UILabel!
    @IBOutlet weak var internalIdLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
