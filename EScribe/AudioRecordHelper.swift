//
//  AudioRecordHelper.swift
//  EScribe
//
//  Created by minhnh on 3/11/17.
//
//

import UIKit
import AVFoundation
import AudioToolbox

protocol NowPlayingUpdateDelegate: class {
    func playerDidGetDuration(duration: TimeInterval)
    func playerDidUpdateTime(timeInterval: TimeInterval)
}

class AudioRecordHelper: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecordHelper()
    
    var audioSession: AVAudioSession?
    var audioRec: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    weak var delegate: NowPlayingUpdateDelegate?
    
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
    
    func stopRecording() {
        guard let audioRecUnwrapped = audioRec else {
            return
        }
        
        if audioRecUnwrapped.isRecording {
            audioRecUnwrapped.stop()
        }
    }
    
    func mergeAudioFiles(uuid: String, numOfParts: Int, completionHandler: @escaping () -> Void) {
        let composition = AVMutableComposition()
        
        guard numOfParts > 0 else {
            completionHandler()
            return
        }
        
        for i in 1 ... numOfParts {
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            
            let partURL = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(uuid)-p\(i).aac")
            
            let asset = AVURLAsset(url: partURL)
            
            let track = asset.tracks(withMediaType: AVMediaTypeAudio)[0]
            
            let timeRange = CMTimeRange(start: CMTimeMake(0, 600), duration: track.timeRange.duration)
            
            try! compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
            
            try! FileManager.default.removeItem(at: partURL)
        }
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let mergeAudioURL = documentDirectoryURL.appendingPathComponent("\(uuid).m4a")! as URL as NSURL
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileTypeAppleM4A
        assetExport?.outputURL = mergeAudioURL as URL
        assetExport?.exportAsynchronously(completionHandler: {
            completionHandler()
        })
    }
    
    func playAudio(filename: String) {
        let url = VariousHelper.shared.getDocumentPath().appendingPathComponent("\(filename).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            delegate?.playerDidGetDuration(duration: audioPlayer!.duration)
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
            audioPlayer?.play()
        } catch let error {
            print("Cannot play audio: \(error.localizedDescription)")
        }
    }
    
    func updateTime(_ timer: Timer) {
        delegate?.playerDidUpdateTime(timeInterval: audioPlayer!.currentTime)
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
    }
    
    func resumeAudio() {
        audioPlayer?.play()
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    // MARK: - Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Yay ok all")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Aw fuck shit happened")
    }
}
