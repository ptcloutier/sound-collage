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
    var audioFilename: URL?
    var recordingIsEnabled = false
    var speakerEnabled: Bool = false
    
    
    private override init() {}
    
    //MARK: Playback
    
    func playback() {
                
        guard let sample = getSample(selectedSampleIndex: selectedSampleIndex!) else {
            print("Playback sample not found")
            return
        }
        guard let title = sample.title else {
            print("Error: audio file has no title.")
            return
        }
        let audioPath = SCDataManager.shared.getFileURL(fileName: title)
        playSound(soundFileURL: audioPath!)
    }
    
    
    
    func getSample(selectedSampleIndex: Int) -> SCAudioFile? {
        
        var selectedSample: SCAudioFile?
        
        guard let user = SCDataManager.shared.user else {
            print("Error: user doesn't exist")
            return nil
        }
        guard let sampleBank = user.currentSampleBank else {
            print("Error retrieving sampleBank for playback")
            return nil
        }
        if (sampleBank.samples?.count)! > 0 { // TODO: all samples need to live in library not samplebank. old samples should be deleted 
            for sample in sampleBank.samples! {
                if sample.sampleBankID == selectedSampleIndex {
                    selectedSample = sample
                }
            }
        }
        return selectedSample
    }
    
    
    
    func playSound (soundFileURL: URL){
        
        if let player = players[soundFileURL] { //player for sound has been found
            
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
                
            } else { // player is in use, create a new, duplicate player
                
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: soundFileURL)
                //use 'try!' because we know the URL worked before.
                
                duplicatePlayer.delegate = self
                //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                
                duplicatePlayers.append(duplicatePlayer)
                //add duplicate to array so it doesn't get removed from memory before finishing
                
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.play()
                print("Played sample with success!")
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do{
                let player = try AVAudioPlayer(contentsOf: soundFileURL)
                players[soundFileURL] = player
                player.prepareToPlay()
                player.play()
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
    
    func createNewSample(){
        if audioRecorder == nil {
            setupRecordingSession()
        } else {
            finishRecording(success: true)
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
        
        let title = UUID.init().uuidString
        SCDataManager.shared.currentSampleTitle = title
        
        audioFilename = getDocumentsDirectory().appendingPathComponent(title)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
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
        
        guard let audioFilenamePath = audioFilename?.path else {
            print("Error: audioFileName is nil")
            return
        }
        guard let index = selectedSampleIndex else {
            print("Error: selectedSampleIndex is nil")
            return
        }
        guard let title = SCDataManager.shared.currentSampleTitle else {
            print("Error: currentSampleTitle is nil")
            return
        }
        let audioFile = SCAudioFile.init(sampleBankID: index, audioPath: audioFilenamePath, title: title )
        print("Recording successful.\naudioPath: \(audioFile.audioPath) , audioTitle: \(audioFile.title)")
        
        guard let user = SCDataManager.shared.user else {
            print("Error: user doesn't exist.")
            return
        }
        guard let sampleBank = user.currentSampleBank else{
            print("Error: sampleBank doesn't exist.")
            return
        }
        guard var samples = sampleBank.samples  else {
            print("Error: samples array not found in sampleBank")
            return
        }
        samples.append(audioFile)
        SCAudioManager.shared.recordingIsEnabled = false // so that we set the keyboard buttons to play
    }
    
    func playbackSource(){
        
        let audioSession = AVAudioSession.sharedInstance()
        
        switch speakerEnabled {
        case true:
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            } catch let error as NSError {
                print("AudioSession error: \(error.localizedDescription)")
            }
            speakerEnabled = false
            print("Audio source: headphone jack")
        case false:
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch let error as NSError {
                print("AudioSession error: \(error.localizedDescription)")
            }
            speakerEnabled = true
            print("Audio source: speaker")
        }
    }
}
