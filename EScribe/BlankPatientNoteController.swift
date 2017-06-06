//
//  BlankPatientNoteController.swift
//  EScribe
//
//  Created by minhnh on 5/23/17.
//
//

import UIKit

class BlankPatientNoteController: ViewControllerWithDragonSDK {

    @IBOutlet weak var blankNoteTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagDictionaryChoice = 2
        
        setupDictateCommandForTextFields()
        
        blankNoteTextView.layer.borderWidth = 3
        blankNoteTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    private func setupDictateCommandForTextFields() {
        for (key, tag) in NameTagAssociation.blankTagDictionary {
            let inputField = view.viewWithTag(tag) as! UITextView
            inputField.setVuiConceptName("\(key)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupFormCommand()
    }
    
    func setupFormCommand() {
        let commandSet = NUSACommandSet(name: "Generate Form Command", description: "Use to generate a predefined patient note form")
        commandSet?.createCommand("createNormalExam", phrase: "normal exam", display: nil, description: "General normal exam form")
//        vuiController.assignCommandSets([commandSet!])
    }
    
    func vuiControllerDidRecognizeCommand(_ id: String!, spokenPhrase: String!, withContent content: String!, placeholderValues: [AnyHashable : Any]!) {
        blankNoteTextView.text = "*Chief Complaint:\nHouse call visit was necessary in lieu of an office visit as this patient is homebound. The reason the patient is homebound is   .  The patient is being seen today for the following chronic problems:   . And the acute issue of   .\n\n*Hospitalizations/ Surgeries\n \n*Treatment\n \n*Family History:\nFather\nMother\nSiblings\n \n*Social History\n \n*History of Present Illness\n \nThe patient is seen for return visit for the following complaints:   . The patient lives in     and is homebound due to   .\n \n*Social History: Patient is not a smoker\n \n*ALCOHOL USE:  Patient denies alcohol use.  \n \n*DRUG USE:  Patient denies drug use.  \n \n*CAFFEINE:  Patient denies caffeine use. \n \n*SEXUAL ACTIVITY:  Sexually active in the past  \n \n*Physical Exam\nGENERAL: Normal. Well developed patient in no obvious distress/discomfort during encounter.\nEYES: Normal. EOMI, sclera clear. \nENMT: Normal. Moist mucus membranes, trachea midline, no swelling. \nHEAD: Normal. NCAT. \nPULMONARY: Normal. Minimal wheezing noted. \nNECK: Normal. Neck is soft, supple, and non-tender to palpation.  No carotid bruits to auscultation.  No lymphadenopathy.  Pt is able to swallow to command. \nCHEST: Normal. Symmetrical chest expansion during deep breaths. \nCARDIOVASCULAR: Normal. RRR. No m/r/g. Radial pulses are palpable and equal bilaterally. CRT < 3 sec B fingers. Extremities are warm to touch. \nBACK: Normal. NO VERTEBRAL TENDERNESS but ROM somewhat limited due to DJD. \nABDOMEN: Normal. Abdomen is soft, flat, and non-tender to palpation.  Hypoactive BS throughout.  Percussive tones are resonant throughout.  No hepatosplenomegaly reported. \nEXTREMITIES: Normal. No edema noted in B ankles/lower legs.\nLYMPHATIC: Normal. No cervical lymphadenopathy. \nSKIN: Normal. No new lesions or rashes appreciated.\nMUSCULOSKELETAL: Normal. Grip strength is 3/5 and equal B hands.  No abnormal movements. muscle weakness. \nNEUROLOGICAL: Normal. CN 2-12 grossly intact.  AO X 3. \nPSYCH: Normal. Affect is appropriate.\n \n*Diagnosis/ Assessment\n \n*Counseling Time:\nAt least additional 30 min on top of regular assessment.  Will also d/w POA. Will also discuss with POA.\n \n*Other Plan:\nAdvised patient/staff/POA to call MD24 House Call (623)374-7774 if they have any question.\n \n*Instructions for Patient Checkout:\nOrders/Requests-\nX-Rays:\t\t Type(s):\t Dx:\nUltrasound:\tType(s):\t\tDx:\nLabs: \tType(s):\t\tDx:\nDME/Equipment-\nItem/Type:\nReason:\nDx:\nReferrals-\nType(s):\nReason(s):\nDx:\nScheduling Requests:\nFollow Up in how many weeks:\nPRN Items:\n               \t Changes:\n                      \t Gate code:\n                    \t   Apt#:\nStatus: OPT OUT, Hospice, Etc.\nD/C Req."
    }
}
