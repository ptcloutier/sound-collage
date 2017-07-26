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
    var selectedSampleIndex: Int = 0
    var selectedSequencerIndex: Int = 0
    var audioRecorder: AVAudioRecorder!
    var audioFilePath: URL?
    var isRecordingModeEnabled = false
    var isEditingModeEnabled = false 
    var isSpeakerEnabled: Bool = false
    var isRecording: Bool = false
    var replaceableFilePath: String?
    var audioEngine: SCAudioEngine!
    var mixerPanels: [String] = []
    var effectControls: [SCEffectControl] = []
    var audioEngineChain: [SCAudioEngine] = []
    var finishedEngines: [SCAudioEngine] = []
    var sequencerSettings: [[Bool]] = []
    var sequencerIsPlaying: Bool = false

    
    
    
    func setupAudioManager(){
        
        self.mixerPanels = [  "Reverb", // 13 reverb presets to choose from
                              "Delay", // delay has 4 parameters
                              "Pitch",
                              "Distortion" // AVAudioUnitDistortion
        ]
        
/* TODO: "Analyzer", // volume, pan, waveform visual, trim/edit capabilities
         "Equalizer", //  AVAudioUnitEQ, AVAudioUnitEQFilterType
         "Time", AVAudioUnitTimeEffect
         "Speed" AVAudioUnitVarispeed */

        
        NotificationCenter.default.addObserver( self, selector: #selector(routeChanged), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
        
        audioSession.requestRecordPermission({ allowed in
            DispatchQueue.main.async {
                if allowed {
                    print("Good to go!")
                } else {
                    print("Request to use microphone denied.")
                }
            }
        })
        observeAudioIO()
    }
    
    

    
    
    
    
    //MARK: Playback
    
    
    
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


    
  
    
    
    
    func removeUsedEngines(){
        
        
        if self.finishedEngines.isEmpty == false {
            
            for (i, fin) in self.finishedEngines.enumerated().reversed() {
                for (j, engine) in self.audioEngineChain.enumerated().reversed() {
                    if fin == engine {
                        fin.stop()
                        engine.stop()
                        self.finishedEngines.remove(at: i)
                        self.audioEngineChain.remove(at: j)
                        print("removed at index:\(j), bye felicia")
                    }
                }
            }
        }
    }
    
    
    
    func playAudio(sampleIndex: Int){
        
        
        
        guard let partialPath = getSample(selectedSampleIndex: sampleIndex) else {
            print("Playback sample not found")
            return
        }
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        
        let fullPath = docsDirectory.appending("/\(partialPath)")
        let fullURL = URL.init(fileURLWithPath: fullPath )
        
        removeUsedEngines()
        
//        let sampleIndex = sampleIndex
        self.audioEngine = SCAudioEngine()
        self.audioEngineChain.append(self.audioEngine)
        
        
        do {
            let audioFile = try AVAudioFile(forReading: fullURL)
            let audioFormat = audioFile.processingFormat
            let audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attach(audioPlayerNode)
            
            // selected effect in effectControl, selectedSamplePad parameter in parameter
            
            let reverb = AVAudioUnitReverb()
            let reverbParameter1 = self.effectControls[0].parameter[selectedSampleIndex]
            reverb.loadFactoryPreset(.plate) // there are thirteen posible presets
            reverb.wetDryMix = reverbParameter1
            audioEngine.attach(reverb)
            
            
            
            let delay = AVAudioUnitDelay()
            var delayFeedback = self.effectControls[1].parameter[selectedSampleIndex]
            
            if delayFeedback>75.0 {
                delayFeedback = 75.0
            }
            delay.feedback = delayFeedback
            
            let delayTime = self.effectControls[2].parameter[selectedSampleIndex]
            delay.delayTime = TimeInterval(delayTime)
            
            let delayLPCutoff = self.effectControls[3].parameter[selectedSampleIndex]
            delay.lowPassCutoff = delayLPCutoff
            
            let delayWetDryMix = self.effectControls[4].parameter[selectedSampleIndex]
            delay.wetDryMix = delayWetDryMix
            
            audioEngine.attach(delay)
            
            
            let pitch = AVAudioUnitTimePitch()
            let pitchParameter = self.effectControls[5].parameter[selectedSampleIndex]
            let pitchZero = -1200
            let pitchValue = Float(pitchParameter)*24
            let sum = pitchZero + Int(pitchValue)
            pitch.pitch = Float(sum)
            
            audioEngine.attach(pitch)
            
            
            
            audioEngine.connect(audioPlayerNode, to: pitch, format: audioFormat)
            audioEngine.connect(pitch, to: delay, format: audioFormat)
            audioEngine.connect(delay, to: reverb, format: audioFormat)
            audioEngine.connect(reverb, to: audioEngine.mainMixerNode, format: audioFormat)
            
            guard let fin = self.audioEngine else {
                print("no engine.")
                return
            }
            
            
            audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {
                
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                // calculate audio tail based on reverb and delay parameters
                var durationInt = Int(round(Double(audioFile.length)/44100))
                if durationInt == 0 {
                    durationInt = 1
                }
                
                let reverbParameter = strongSelf.effectControls[0].parameter[strongSelf.selectedSampleIndex]
                let reverbTime = round((Float(reverbParameter/2)/10))
                durationInt += Int(reverbTime)
                
                let delayParams = strongSelf.effectControls[1].parameter[strongSelf.selectedSampleIndex]
                let delayTime = round(Float(delayParams)/10)
                durationInt += Int(delayTime)
                
                
                let duration = DispatchTimeInterval.seconds(durationInt)
               
                let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
                delayQueue.asyncAfter(deadline: .now()+duration){
                    
                    [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.finishedEngines.append(fin)
                }
            })

            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch _ {
                print("Play session Error")
            }
            audioPlayerNode.play()
            print("Playing audiofile at \(fullURL.absoluteString)")
        } catch let error {
            print("Could not play sound file! \(error.localizedDescription)")
        }
    }
    
    
    
    func effectsParametersDidChange(){
       
//        SCDataManager.shared.user?.currentSampleBank?.effectSettings
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
        
     
        isRecording = true

        // TODO: there are many different names for the same thing throughout the app, audioFilepath, sampleURl, titleURL, just need to pick the most descriptive name
        guard let currentSampleBankID = SCDataManager.shared.user?.currentSampleBank?.id else {
            print("current sample bank id not found.")
            return
        }
        
        let samplePadIndex = selectedSampleIndex         
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
            isRecording = false
            isRecordingModeEnabled = false
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
        isRecording = false
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
            if key == selectedSampleIndex.description {
                sampleBank.samples[key] = audioURL as AnyObject?
                print("Audio file recorded and saved at \(audioURL.description)")
            }
        }
        removeAudioFile(at: self.replaceableFilePath)
        SCDataManager.shared.user?.currentSampleBank? = sampleBank
        isRecordingModeEnabled = false // so that we set the keyboard buttons to play
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
            observeAudioIO()
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
