//
//  AudioPlayer.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/11/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


class SCAudioManager: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    static let shared = SCAudioManager()
    
    var players = [URL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var selectedSampleIndex: Int?
    var audioRecorder: AVAudioRecorder!
    var audioFilePath: URL?
    var isRecordingModeEnabled = false
    var isSpeakerEnabled: Bool = false
    var isRecording: Bool = false
    
    private override init() {}
    
    
    
    //MARK: Playback
    
    func playback() {
        
        guard let path = getSample(selectedSampleIndex: selectedSampleIndex!) else {
            print("Playback sample not found")
            return
        }
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        
        let filepath = docsDirectory.appending("/\(path)")
        let audioPath = URL.init(fileURLWithPath: filepath )
        
        playSound(soundFileURL: audioPath)
    }
    
    
    
    func getSample(selectedSampleIndex: Int) -> String? {
        
        var selectedSample: String?
        
        guard let user = SCDataManager.shared.user else {
            print("Error: user doesn't exist")
            return nil
        }
        guard let sampleBank = user.currentSampleBank else {
            print("Error retrieving sampleBank for playback")
            return nil
        }
        for key in sampleBank.samples.keys {
            if key == selectedSampleIndex.description {
                selectedSample = sampleBank.samples[key] as! String?
            }
        }
        
        return selectedSample
    }
    
    
//    
//    func createFileAtPath(soundFileURL: URL) -> URL? {
//        
//        // Get a file for AVAudioPlayer
//        do {
//            let soundData = try Data.init(contentsOf: soundFileURL)
//            let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending(soundFileURL.description)
//            
//            guard let filePath = docsPath else {
//                print("Docs path not found.")
//                return nil
//            }
//            do {
//                try soundData.write(to: URL(fileURLWithPath:filePath), options: .atomic)
//                return URL(fileURLWithPath:filePath)
//            } catch {
//                print(error)
//            }
//        }
//        catch {
//            print(error)
//        }
//        return nil
//    }
//    
//    
    
    func playSound(soundFileURL: URL){
        
        print("Attempting playback with path: \(soundFileURL)")
        
        
        if let player = players[soundFileURL] { //player for sound has been found
            
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
                print("Playing audiofile at \(soundFileURL)")
                
            } else { // player is in use, create a new, duplicate player
                
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: soundFileURL)
                //use 'try!' because we know the URL worked before.
                
                duplicatePlayer.delegate = self
                //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                
                duplicatePlayers.append(duplicatePlayer)
                //add duplicate to array so it doesn't get removed from memory before finishing
                
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.play()
                print("Playing audiofile at \(soundFileURL)")
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do{
                
                let player = try AVAudioPlayer(contentsOf: soundFileURL, fileTypeHint: "m4a")
                
                players[soundFileURL] = player
                player.prepareToPlay()
                player.play()
                print("Playing audiofile at \(soundFileURL)")
            } catch {
                print("Could not play sound file!")
            }
        }
    }
    
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at: duplicatePlayers.index(of: player)!)
        //Remove the duplicate player once it is done
    }
    
    
    
    //MARK: Recording
    
    func recordNew() {
        
        if audioRecorder == nil {
            setupRecordingSession()
        }
    }
    
    
    
    func setupRecordingSession(){
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                        self.isRecording = true
                    } else {
                        print("Failed to record!")
                    }
                }
            }
        } catch {
            print("Failed to record!")
        }
    }
    
    
    
    func startRecording() {
        // TODO: there are many different names for the same thing throughout the app, audioFilepath, sampleURl, titleURL, just need to pick the most descriptive name
        guard let currentSampleBankID = SCDataManager.shared.user?.currentSampleBank?.id else {
            print("current sample bank id not found.")
            return
        }
        guard let samplePadIndex = selectedSampleIndex else {
            print("selectedSample index not found.")
            return
        }
        let audioFileName = "sampleBank_\(currentSampleBankID)_samplePadIndex_\(samplePadIndex)"
        let audioFileFullPath = audioFileName.appending(".m4a")
        SCDataManager.shared.currentSampleTitle = audioFileFullPath
        
        self.audioFilePath  = getDocumentsDirectory().appendingPathComponent(audioFileFullPath)
        
//        SCDataManager.shared.replaceAudioFileAtPath(filePath: self.audioFilePath!)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: self.audioFilePath!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
            self.isRecording = false
        }
    }
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    
    func finishRecording(success: Bool) {
        
        audioRecorder?.stop()
        audioRecorder = nil
        self.isRecording = false
        print("Audio recording stopped.")
        
        guard let audioURL = audioFilePath?.lastPathComponent else {
            print("Error: audioFilePath is nil")
            return
        }
        guard let user = SCDataManager.shared.user else {
            print("Error: user doesn't exist.")
            return
        }
        guard let sampleBank = user.currentSampleBank else{
            print("Error: sampleBank doesn't exist.")
            return
        }
        for key in sampleBank.samples.keys{
            if key == selectedSampleIndex?.description {
                sampleBank.samples[key] = audioURL as AnyObject?
                print("Audio file recorded and saved at \(audioURL.description)")
            }
            
        }
        
        SCDataManager.shared.user?.currentSampleBank? = sampleBank
        SCAudioManager.shared.isRecordingModeEnabled = false // so that we set the keyboard buttons to play
    }
    
    
    
    func playbackSource(){
        
        let audioSession = AVAudioSession.sharedInstance()
        
        switch isSpeakerEnabled {
        case true:
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            } catch let error as NSError {
                print("AudioSession error: \(error.localizedDescription)")
            }
            isSpeakerEnabled = false
            print("Audio source: headphone jack")
        case false:
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch let error as NSError {
                print("AudioSession error: \(error.localizedDescription)")
            }
            isSpeakerEnabled = true
            print("Audio source: speaker")
        }
    }
}
