//
//  AudioRecordHelper.swift
//  EScribe
//
//  Created by minhnh on 3/11/17.
//
//

import UIKit
import AVFoundation

class AudioRecordHelper: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecordHelper()
    
    var audioSession: AVAudioSession?
    var audioRec: AVAudioRecorder?
    
    func setup() {
        // Init recorder session
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession?.setActive(true)
            
            audioSession?.requestRecordPermission({ (allowed) in
                if allowed {
                    print("Mic authorized")
                } else {
                    print("Mic access declined")
                }
            })
        } catch {
            print("Failed to init AV session")
        }
    }
    
    func record(filename: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirect = paths[0]
        
        let writePath = docDirect.appendingPathComponent(filename + ".aac")
        let audioUrl = URL.init(fileURLWithPath: writePath.path)
        
        let settings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000.0,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRec = try AVAudioRecorder(url: audioUrl, settings: settings)
            audioRec?.delegate = self
            audioRec?.isMeteringEnabled = true
            audioRec?.prepareToRecord()
            audioRec?.record()
        } catch let error {
            print(error)
        }
    }
    
    func stop() {
        if audioRec!.isRecording {
            audioRec?.stop()
        }
    }
    
    // Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Yay ok all")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Aw fuck shit happened")
    }
}
