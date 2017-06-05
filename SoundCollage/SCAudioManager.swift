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
    
    var recordedOutputFile: AVAudioFile?
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
    var activeEffects: [AVAudioUnit] = []
    var effectsSettings: [[[Float]]] = [[[]]] // time to make a struct
    var effectParameterSettings: [[Float]] = [[]]
    var audioEngine: SCAudioEngine!
    var effects: [SCEffect] = []
    var engineChain: [[SCAudioEngine]] = []
    var pitchIsActive: Bool = false
    var reverbIsActive: Bool = false
    var delayIsActive: Bool = false

    
    
    
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
        setupEngines()
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
    
    
    func setupEngines(){
       
       
        while engineChain.count<16 {
        var engines: [SCAudioEngine] = []
        let audioEngine = SCAudioEngine()
        engines.append(audioEngine)
        engineChain.append(engines)
        }
        
    }
    
    
    
    func setupEffects(){
        
        let reverb = SCEffect.init(effect: AVAudioUnitReverb)
        let delay = SCEffect.init(effect: AVAudioUnitDelay)
        let pitch = SCEffect.init(effect: AVAudioUnitTimePitch)
        effects = [reverb, delay, pitch]
        
        for x in effects {
            
            print("\(x.effect.name)")
            
        }
    }
    

    
    
    func toggleEffect(index: Int){
        
        // activate effect by adding it to activeEffects array
        let selection = effects[index]
        
        if selection.effect.name == "AUNewTimePitch" {
        switch pitchIsActive {
        case true:
            pitchIsActive = false
            print("\(selection.effect.name) turned off.")
        case false:
            pitchIsActive = true
            print("\(selection.effect.name) turned on.")
        }
        }
        if selection.name == "AUDelay" {
            switch delayIsActive {
            case true:
                delayIsActive = false
                print("\(selection.effect.name) turned off.")
            case false:
                delayIsActive = true
                print("\(selection.effect.name) turned on.")
            }
        }
        if selection.name == "AUReverb2" {
            switch reverbIsActive {
            case true:
                reverbIsActive = false
                print("\(selection.effect.name) turned off.")

            case false:
                reverbIsActive = true
                print("\(selection.effect.name) turned on.")
            }
        }
    }
    
    
        
    
    
    func playAudio(soundFileURL: URL){
        

        guard let sampleIndex = self.selectedSampleIndex else {
            print("No selected sample index.")
            return
        }
        var engines = engineChain[sampleIndex]
        for engine in engines {
            if engine.isRunning == false {
            self.audioEngine = engine
            } else {
                self.audioEngine = SCAudioEngine()
                engines.append(self.audioEngine)
            }
        }
        
        guard let audioEngine = self.audioEngine else {
            print("Audio engine not found.")
            return
        }
        
        do {
            let audioFile = try AVAudioFile(forReading: soundFileURL)
            let audioFormat = audioFile.processingFormat
            let audioPlayerNode = AVAudioPlayerNode()
            
            if self.effectIsSelected == false {
                audioEngine.attach(audioPlayerNode)
                audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFormat)
                audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: audioFormat)

            } else {
                
                
                let effectParameters = self.effects[sampleIndex].parameters
                
                
                let reverbEffect = AVAudioUnitReverb()
                let delayEffect = AVAudioUnitDelay()
                let pitchEffect = AVAudioUnitTimePitch()

                
                audioEngine.attach(audioPlayerNode)
                
                let pitchZero = -1200
                let pitchParam = Float(effectParameters[2])*24
                let pitch = pitchZero + Int(pitchParam)
                pitchEffect.pitch = Float(pitch)
                audioEngine.attach(pitchEffect)
                print("Pitch: \(pitch)")
                
                reverbEffect.loadFactoryPreset(.mediumChamber)
                let x = Float(effectParameters[0])/2
                let y = 100.0 - Float(effectParameters[1])
                let xy = x+y
                let wetDryParam = xy 
                reverbEffect.wetDryMix = wetDryParam
                audioEngine.attach(reverbEffect)
                
                
                let delayTime = effectParameters[0]
                let format = Float(50.0)
                delayEffect.delayTime = TimeInterval(delayTime/format)
                delayEffect.feedback = effectParameters[1]
                audioEngine.attach(delayEffect)
      
                // Sound effect connections

                audioEngine.connect(audioPlayerNode, to: pitchEffect, format: audioFormat)
                audioEngine.connect(pitchEffect, to: reverbEffect, format: audioFormat)
                audioEngine.connect(reverbEffect, to: delayEffect, format: audioFormat)
                audioEngine.connect(delayEffect, to: audioEngine.mainMixerNode, format: audioFormat)
                
            }
            
            switch audioEngine.doCreateNewEngine {
            case true:
                audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {
//                    [weak self] in
//                    guard let strongSelf = self else {
//                        return
//                    }
                    
                    let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
                    delayQueue.asyncAfter(deadline: .now() + 10.0) {
                        audioEngine.detachNode(audioPlayerNode: audioPlayerNode)
                        audioEngine.resetEngine()
                    }
                })
            case false:
                audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {
//                    [weak self] in
//                    guard let strongSelf = self else {
//                        return
//                    }
                    audioEngine.plays+=1
                    let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
                    delayQueue.asyncAfter(deadline: .now() + 10.0) {
                        audioEngine.detachNode(audioPlayerNode: audioPlayerNode)
                    }
                })
            }
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch _ {
                print("Play session Error")
            }
            audioPlayerNode.play()
            audioEngine.plays += 1
            print("Engine plays: \(audioEngine.plays)")
            print("Playing audiofile at \(soundFileURL)")
        } catch let error {
            print("Could not play sound file! \(error.localizedDescription)")
        }
    }
    
    
    
    func handleEffectsParameters(point: CGPoint, sampleIndex: Int) {
        
        let effectParameters = self.effects[sampleIndex].parameters
        
        effectParameters.removeAll()
        
        var x = Float(point.x)/2
        if x>100{
            x=100
        }
        if x<0 {
            x=0
        }
        var y = (200.0-Float(point.y))/2
        if y>100{
            y=100
        }
        if y<0{
            y=0
        }
        
        let xy = (x+y)/2
        
        effectParameters[0] = x
        effectParameters[1] = y
        effectParameters[2] = xy
        
        print("Parameters: \(x), \(y), \(xy)")
        
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
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVLinearPCMIsNonInterleaved: true
        ] as [String : Any]
        
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
