//
//  InputWrapperTextView.swift
//  EScribe
//
//  Created by minhnh on 3/23/17.
//
//

import UIKit
import QuartzCore

class InputWrapperTextView: UITextView {

    override func awakeFromNib() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor(red:207.0/255.0, green:207.0/255.0, blue:207.0/255.0, alpha:255.0/255.0).cgColor
        layer.cornerRadius = 4.0
    }

}
