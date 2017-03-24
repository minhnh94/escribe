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
        let docDirect = VariousHelper.shared.getDocumentPath()
        
        let writePath = docDirect.appendingPathComponent(filename + ".aac")
        let audioUrl = URL.init(fileURLWithPath: writePath.path)
        
        let settings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
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
    
    func mergeAudioFiles(uuid: String, numOfParts: Int) {
        let composition = AVMutableComposition()
        
        for i in 1 ... numOfParts {
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            
            let partURL = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(uuid)-p\(i).aac")
            
            let asset = AVURLAsset(url: partURL)
            
            let track = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
            
            let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: track.timeRange.duration)
            
            try! compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
        }
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let mergeAudioURL = documentDirectoryURL.appendingPathComponent("\(uuid).m4a")! as URL as NSURL
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileTypeAppleM4A
        assetExport?.outputURL = mergeAudioURL as URL
        assetExport?.exportAsynchronously(completionHandler:
            {
                switch assetExport!.status
                {
                case AVAssetExportSessionStatus.failed:
                    print("failed \(assetExport?.error)")
                case AVAssetExportSessionStatus.cancelled:
                    print("cancelled \(assetExport?.error)")
                case AVAssetExportSessionStatus.unknown:
                    print("unknown\(assetExport?.error)")
                case AVAssetExportSessionStatus.waiting:
                    print("waiting\(assetExport?.error)")
                case AVAssetExportSessionStatus.exporting:
                    print("exporting\(assetExport?.error)")
                default:
                    print("Audio Concatenation Complete")
                }
        })
    }
    
    // Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Yay ok all")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Aw fuck shit happened")
    }
}
