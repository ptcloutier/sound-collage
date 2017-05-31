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
    
    
    override private init() {}
    
    static let shared = SCAudioManager()
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var selectedSampleIndex: Int?
    var audioRecorder: AVAudioRecorder!
    var audioFilePath: URL?
    var isRecordingModeEnabled = false
    var isEditingModeEnabled = false 
    var isSpeakerEnabled: Bool = false
    var isRecording: Bool = false
    var replaceableFilePath: String?
    var effectIsSelected: Bool = false
    var players: [SCAudioPlayerNode] = []
    var activeEffects: [AVAudioUnit] = []
    var effects: [AVAudioUnit] = []
    
    
    
    //MARK: Basic setup 
    
    
    func setupAudioManager(){
        let nc = NotificationCenter.default
        nc.addObserver( self, selector: #selector(routeChanged), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
        
        audioSession.requestRecordPermission({ allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("Good to go!")
                } else {
                    print("Request to use microphone denied.")
                }
            }
        })
        setupEffects()
        observeAudioIO()
    }
    
    
    
    //MARK: Playback
    
    
    func playback() {
        
        guard let partialPath = getSample(selectedSampleIndex: selectedSampleIndex!) else {
            print("Playback sample not found")
            return
        }
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        
        let fullPath = docsDirectory.appending("/\(partialPath)")
        let fullURL = URL.init(fileURLWithPath: fullPath )
        
        playAudio(soundFileURL: fullURL)
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
    

    
    //MARK: Effects 
    
    
    func setupEffects(){
        
        let pitchEffect = AVAudioUnitTimePitch()
        let distortionEffect = AVAudioUnitDistortion()
        let delayEffect = AVAudioUnitDelay()
        let reverbEffect = AVAudioUnitReverb()
        effects = [pitchEffect, distortionEffect, delayEffect, reverbEffect]
    }
    
    
    
    func variablePitchEffect(pitch: Float, audioPlayerNode: AVAudioPlayerNode){
        
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = pitch
            
            self.audioEngine.attach(changePitchEffect)
            
            self.audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
            
            self.audioEngine.connect(changePitchEffect, to: self.audioEngine.mainMixerNode, format: nil)
        
    }
    
    
    
    func distortionEffect(audioPlayerNode: AVAudioPlayerNode){
        
        let distortionEffect = AVAudioUnitDistortion()
        distortionEffect.loadFactoryPreset(.multiDistortedFunk)
        self.audioEngine.attach(distortionEffect)
        self.audioEngine.connect(audioPlayerNode, to: distortionEffect, format: nil)
        self.audioEngine.connect(distortionEffect, to: self.audioEngine.mainMixerNode, format: nil)
        
    }
    
    
    func delayEffect(audioPlayerNode: AVAudioPlayerNode){
        
        let delayEffect = AVAudioUnitDelay()
        delayEffect.delayTime = 0.5
        delayEffect.feedback = 0.1
        self.audioEngine.attach(delayEffect)
        self.audioEngine.connect(audioPlayerNode, to: delayEffect, format: nil)
        self.audioEngine.connect(delayEffect, to: self.audioEngine.mainMixerNode, format: nil)
        
    }
    
    
    /*if self.distortionEffectIsSelected == true {
     distortionEffect(audioPlayerNode: audioPlayerNode)
     }
     if self.pitchEffectIsSelected == true {
     variablePitchEffect(pitch: 1000, audioPlayerNode: audioPlayerNode)
     }
     if self.delayEffectIsSelected == true {
     delayEffect(audioPlayerNode: audioPlayerNode)
     }
     if self.reverbEffectIsSelected == true {
     let reverbEffect = AVAudioUnitReverb()
     reverbEffect.loadFactoryPreset(.cathedral)
     let format = reverbEffect.inputFormat(forBus: 0)
     
     reverbEffect.wetDryMix = 0.75
     self.audioEngine.attach(reverbEffect)
     self.audioEngine.connect(audioPlayerNode, to: reverbEffect, format: format)
     self.audioEngine.connect(reverbEffect, to: self.audioEngine.mainMixerNode, format: format)
    */
    
    func activateEffect(index: Int){
        
        // activate effect by adding it to activeEffects array
        let selection = effects[index]
        print("\(selection.name)")
        
        
    }
    
    
    func deactivateEffect(index: Int){
        
        // deactivate effect by removing it 
        
        
        
    }
    
    
    
    
    func playAudio(soundFileURL: URL){
        
        
        if self.audioEngine == nil {
            self.audioEngine = AVAudioEngine()
        }
        do {
            let audioFile = try AVAudioFile(forReading: soundFileURL)
            
            let audioPlayerNode = SCAudioPlayerNode()
            audioEngine.attach(audioPlayerNode)
            
            if self.effectIsSelected == false {
                audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
            } else {
                let audioMixer = AVAudioMixerNode()
                audioEngine.connect(audioMixer, to: audioEngine.mainMixerNode, format: nil)
                
                
            }
            
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
                delayQueue.asyncAfter(deadline: .now() + 2.0) {
                    strongSelf.detachNode(audioPlayerNode: audioPlayerNode)
                }
            })
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch _ {
                print("Play session Error")
            }
            audioPlayerNode.play()
            print("Playing audiofile at \(soundFileURL)")
        } catch {
            print("Could not play sound file!")
        }
    }
    
    
    
    
    
    func detachNode(audioPlayerNode: AVAudioPlayerNode){
        self.audioEngine.disconnectNodeInput(audioPlayerNode)
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
        
        let sampleID = getSampleID(samplePadIndex: samplePadIndex)
        let audioType = ".aac"
        let newPath = "sampleBank_\(currentSampleBankID)_pad_\(samplePadIndex)_id_\(sampleID)\(audioType)"
        let newFullURL = getDocumentsDirectory().appendingPathComponent(newPath)
        SCDataManager.shared.currentSampleTitle = newFullURL.absoluteString
        self.replaceableFilePath = "sampleBank_\(currentSampleBankID)_pad_\(samplePadIndex)_id_\(sampleID-1)\(audioType)"
        self.audioFilePath  = newFullURL
        
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
    
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
    private func getSampleID(samplePadIndex: Int) ->Int {
        
        let userDefaults = UserDefaults.standard
        
        guard let id = userDefaults.value(forKey: "samplePad_\(samplePadIndex)_sampleID") else {
            userDefaults.set(0, forKey: "samplePad_\(samplePadIndex)_sampleID")
            return 0
        }
        let sampleID = id as! Int
        userDefaults.set(sampleID+1, forKey: "samplePad_\(samplePadIndex)_sampleID")
        return sampleID+1
    }
    
    
    
    private func removeAudioFile(at path: String?) {
        
        guard let filePath = path else {
            print("Path not found.")
            return
        }
        let fullURL = getDocumentsDirectory().appendingPathComponent( filePath)

        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: fullURL)
        } catch {
            print("Could not remove file at path.")
        }
    }
    
    
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    
    func finishRecording(success: Bool) {
        
        audioRecorder?.stop()
        audioRecorder = nil
        self.postRecordingFinishedNotification()
        self.isRecording = false
        print("Audio recording stopped.")
        
        guard let audioURL = audioFilePath?.lastPathComponent else {
            print("Error: audioFilePath is nil")
            return
        }
        guard let sampleBank = SCDataManager.shared.user?.currentSampleBank else{
            print("Error: sampleBank doesn't exist.")
            return
        }
        for key in sampleBank.samples.keys{
            if key == selectedSampleIndex?.description {
                sampleBank.samples[key] = audioURL as AnyObject?
                print("Audio file recorded and saved at \(audioURL.description)")
            }
        }
        removeAudioFile(at: self.replaceableFilePath)
        SCDataManager.shared.user?.currentSampleBank? = sampleBank
        SCAudioManager.shared.isRecordingModeEnabled = false // so that we set the keyboard buttons to play
    }
    
    
    private func postRecordingFinishedNotification(){
        let notification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    
    //MARK: Audio i/o
    
    func observeAudioIO(){
        
        if SCAudioManager.shared.isHeadsetPluggedIn() == true {
            SCAudioManager.shared.isSpeakerEnabled = false
        } else {
            SCAudioManager.shared.isSpeakerEnabled = true
        }
        SCAudioManager.shared.setAudioPlaybackSource()
    }
    
    
    
    
    func routeChanged(notification: Notification){
        
        guard let userInfo = notification.userInfo else {
            print("No notification userInfo.")
            return
        }
        let routeChangedReason = userInfo[AVAudioSessionRouteChangeReasonKey] as! Int
        if routeChangedReason == 1 || routeChangedReason == 2 {
            
        }
        print("reason : \(routeChangedReason)")
    }
    
    
    
    func isHeadsetPluggedIn() -> Bool {
        
        let route = audioSession.currentRoute
        var result = true
        for description in route.outputs {
            if description.portType == AVAudioSessionPortHeadphones {
                result = true
            } else {
                result = false
            }
        }
        return result
    }
    
    
    
    
    func setAudioPlaybackSource(){
        
        let audioSession = AVAudioSession.sharedInstance()
        
        switch isSpeakerEnabled {
        case true:
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch let error as NSError {
                print("AudioSession error: \(error.localizedDescription)")
            }
            print("Audio source: speaker")
        case false:
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            } catch let error as NSError {
                print("AudioSession error: \(error.localizedDescription)")
            }
            print("Audio source: headphone output")
        }
    }
    
    
}
