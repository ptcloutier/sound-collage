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
    var mixerPanels: [String : [String]] = [:]
    var effectControls: [[SCEffectControl]] = []
    var audioEngineChain: [SCAudioEngine] = []
    var finishedEngines: [SCAudioEngine] = []
    var sequencerSettings: [[Bool]] = []
    var sequencerIsPlaying: Bool = false
    var audioBuffer = AVAudioPCMBuffer()
    var outputFile = AVAudioFile()
    var recordingEngine = AVAudioEngine()
    var isRecordingSoundCollage: Bool = false 
    var outputFileURL: URL?
    var sampler: AVAudioUnitSampler?
    var audioController: SCGAudioController?
    
    
    
    
    
    func setupAudioManager(){
        
        self.audioController = SCGAudioController.init()
        self.audioController?.delegate = self as? SCGAudioControllerDelegate
        
        
        setupEffects()
        
//        NotificationCenter.default.addObserver( self, selector: #selector(routeChanged), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
//        
        
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
                        print("removed at index:\(j)")
                    }
                }
            }
        }
    }
    
    
    func getPathForSampleIndex(sampleIndex: Int) -> String? {
        
        guard let partialPath = getSample(selectedSampleIndex: sampleIndex) else {
            print("Playback sample not found")
            return nil
        }
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let fullPath = docsDirectory.appending("/\(partialPath)")
        
        return fullPath
    }
    
    
    
    func getAudioFileForPath(path: String) -> AVAudioFile? {
        
        var audioFile: AVAudioFile
       
        let url = URL.init(fileURLWithPath: path )
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            return audioFile
        } catch let error {
            print("Could not play sound file. \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    func setupReverb(sampleIndex: Int) -> AVAudioUnitReverb {
        
        let reverb = AVAudioUnitReverb()
        let reverbParams = effectControls[0]
        if let reverbValue: Float = Float(String(format: "%.0f", reverbParams[0].parameter[sampleIndex]*100.0)) {
            reverb.loadFactoryPreset(.plate) // there are thirteen possible presets
            reverb.wetDryMix = reverbValue
        }
        return reverb
    }
    
    
    
    func setupDelay(sampleIndex: Int) -> AVAudioUnitDelay {
        
        let delay = AVAudioUnitDelay()
        let delayParams = effectControls[1]
        let delayWetDryMixValue = delayParams[0].parameter[sampleIndex] * 100.0
        delay.wetDryMix = delayWetDryMixValue
        let delayTime = delayParams[1].parameter[sampleIndex]
        delay.delayTime = TimeInterval(delayTime)
        let delayFeedback = delayParams[2].parameter[sampleIndex] * 80.0
        delay.feedback = delayFeedback
        let delayLPCutoff = delayParams[3].parameter[sampleIndex] * 6000.0 // 10 -> (samplerate/2), default 15000
        delay.lowPassCutoff = delayLPCutoff
        return delay
    }
    
    
    
    func setupPitchShift(sampleIndex: Int) -> AVAudioUnitTimePitch {
        
        let pitch = AVAudioUnitTimePitch()
        let pitchParams = effectControls[2]
        let pitchUp = pitchParams[0].parameter[sampleIndex] * 100.0
        let pitchUpValue = pitchUp * 24.0
        let posiPitch = pitchUpValue+1.0
        let pitchDown = pitchParams[1].parameter[sampleIndex] * 100.0
        let pitchDownValue = pitchDown * 24.0
        let negiPitch = (pitchDownValue+1.0) * -1.0
        pitch.pitch = posiPitch + negiPitch
        return pitch
    }
    
    
    
    func setupDistortion(sampleIndex: Int) -> AVAudioUnitDistortion {
        
        let distortion = AVAudioUnitDistortion()
        let distortionParams = effectControls[4]
        let preGainValue = distortionParams[0].parameter[sampleIndex] * 100.0// range -80.0 -> 20.0
        distortion.preGain = Float(preGainValue - 80.0)
        let dmix = distortionParams[1].parameter[sampleIndex] * 100.0
        distortion.wetDryMix = dmix
        return distortion
    }
    
    
    func setupTimeStretch(sampleIndex: Int) -> AVAudioUnitVarispeed {
        
        let time = AVAudioUnitVarispeed()
        let timeParams = effectControls[3]
        let timeRateUp = 1.0 + timeParams[0].parameter[sampleIndex] * 4.0
        let timeRateDown = timeParams[1].parameter[sampleIndex] * 0.75
        let rateValue = Float(timeRateUp - timeRateDown)
        time.rate = rateValue
        return time
    }
    
    func playAudio(sampleIndex: Int){ // self.audioController.startRecording(), self.audioController.stopRecording()
        
        // audioManager multiple engines
        removeUsedEngines()
        self.audioEngine = SCAudioEngine()
        self.audioEngineChain.append(self.audioEngine)
        
        guard let path = getPathForSampleIndex(sampleIndex: sampleIndex) else { return }
        guard let audioFile = getAudioFileForPath(path: path) else { return }
        let audioFormat = audioFile.processingFormat
        
        // set up nodes
        let audioPlayerNode = AVAudioPlayerNode()
        let reverb = setupReverb(sampleIndex: sampleIndex)
        let delay = setupDelay(sampleIndex: sampleIndex)
        let pitch = setupPitchShift(sampleIndex: sampleIndex)
        let time = setupTimeStretch(sampleIndex: sampleIndex)
        let distortion = setupDistortion(sampleIndex: sampleIndex)
        
        // attach nodes to engine 
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(reverb)
        audioEngine.attach(delay)
        audioEngine.attach(pitch)
        audioEngine.attach(time)
        audioEngine.attach(distortion)
        
        
        // make engine connections
        audioEngine.connect(audioPlayerNode, to: pitch, format: audioFormat)
        audioEngine.connect(pitch, to: time, format: audioFormat)
        audioEngine.connect(time, to: distortion, format: audioFormat)
        audioEngine.connect(distortion, to: delay, format: audioFormat)
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
            
            let reverbParameter = strongSelf.effectControls[0][0].parameter[sampleIndex]
            let reverbTime = round(Float(reverbParameter * 10.0))
            durationInt += Int(reverbTime)
            
            let delayParams = strongSelf.effectControls[1][2].parameter[sampleIndex]
            let delayTime = round(Float(delayParams * 20.0))
            durationInt += Int(delayTime)
            
            let duration = DispatchTimeInterval.seconds(durationInt)
            
            let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
            delayQueue.asyncAfter(deadline: .now()+duration){
                
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                let serialQueue = DispatchQueue(label: "myqueue")
                
                serialQueue.sync {
                    strongSelf.finishedEngines.append(fin)
                }
                
            }
        })
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch _ {
            print("Play session Error")
        }
        audioPlayerNode.play()
        print("Playing audiofile at \(path)")
    }
    
    
    
    func effectsParametersDidChange(values: [Int], sliderValue: Float) {
        
        let mixerPanelIdx = Int(values[0])
        let sliderIdx = Int(values[1])
        let selectedSamplePad = Int(values[2])
 
        
        self.effectControls[mixerPanelIdx][sliderIdx].parameter[selectedSamplePad] = sliderValue
        SCDataManager.shared.user?.currentSampleBank?.effectSettings = self.effectControls
        SCDataManager.shared.saveObjectToJSON()
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
        self.audioFilePath = newFullURL
        
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
        isRecordingModeEnabled = false
        SCDataManager.shared.saveObjectToJSON()
    }
    
    
    
    
    
    private func postRecordingFinishedNotification(){
        
        let notification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    
    
    //MARK: Effects
    
    
    private func setupEffects(){
        
        self.mixerPanels = ["Reverb" : ["Mix", "", "", "", ""], // "Presets", "SmallRoom", "MediumRoom", "LargeRoom", "MediumHall", "LargeHall", "Plate", "MediumChamber", "LargeChamber", "Cathedral", "LargeRoom2", "MediumHall2", "MediumHall3", "LargeHall2"],
            
            /*  AVAudioUnitReverbPresetSmallRoom       = 0,
             AVAudioUnitReverbPresetMediumRoom      = 1,
             AVAudioUnitReverbPresetLargeRoom       = 2,
             AVAudioUnitReverbPresetMediumHall      = 3,
             AVAudioUnitReverbPresetLargeHall       = 4,
             AVAudioUnitReverbPresetPlate           = 5,
             AVAudioUnitReverbPresetMediumChamber   = 6,
             AVAudioUnitReverbPresetLargeChamber    = 7,
             AVAudioUnitReverbPresetCathedral       = 8,
             AVAudioUnitReverbPresetLargeRoom2      = 9,
             AVAudioUnitReverbPresetMediumHall2     = 10,
             AVAudioUnitReverbPresetMediumHall3     = 11,
             AVAudioUnitReverbPresetLargeHall2      = 12 */
            "Delay" : ["Mix", "Delay Time", "Feedback", "Cutoff", ""], // AVAudioUnitDelay
            "Pitch" : ["Pitch Up", "Pitch Down", "", "", ""], //AVAudioUnitTimePitch
            "Distortion" : ["Mix", "Gain", "", "", ""],//, "Presets", "DrumsBitBrush", "DrumsBufferBeats", "DrumsLoFi", "MultiBrokenSpeaker", "MultiCellphoneConcert", "MultiDecimated1", "MultiDecimated2" ,"MultiDecimated3" ,"MultiDecimated4", "MultiDistortedFunk", "MultiDistortedCubed", "MultiDistortedSquared", "MultiEcho1", "MultiEcho2", "MultiEchoTight1", "MultiEchoTight2", "MultiEverythingIsBroken", "SpeechAlienChatter", "SpeechCosmicInterference", "SpeechGoldenPi", "SpeechRadioTower", "SpeechWaves"]
            // AVAudioUnitDistortion
            /*  AVAudioUnitDistortionPresetDrumsBitBrush           = 0,
             AVAudioUnitDistortionPresetDrumsBufferBeats        = 1,
             AVAudioUnitDistortionPresetDrumsLoFi               = 2,
             AVAudioUnitDistortionPresetMultiBrokenSpeaker      = 3,
             AVAudioUnitDistortionPresetMultiCellphoneConcert   = 4,
             AVAudioUnitDistortionPresetMultiDecimated1         = 5,
             AVAudioUnitDistortionPresetMultiDecimated2         = 6,
             AVAudioUnitDistortionPresetMultiDecimated3         = 7,
             AVAudioUnitDistortionPresetMultiDecimated4         = 8,
             AVAudioUnitDistortionPresetMultiDistortedFunk      = 9,
             AVAudioUnitDistortionPresetMultiDistortedCubed     = 10,
             AVAudioUnitDistortionPresetMultiDistortedSquared   = 11,
             AVAudioUnitDistortionPresetMultiEcho1              = 12,
             AVAudioUnitDistortionPresetMultiEcho2              = 13,
             AVAudioUnitDistortionPresetMultiEchoTight1         = 14,
             AVAudioUnitDistortionPresetMultiEchoTight2         = 15,
             AVAudioUnitDistortionPresetMultiEverythingIsBroken = 16,
             AVAudioUnitDistortionPresetSpeechAlienChatter      = 17,
             AVAudioUnitDistortionPresetSpeechCosmicInterference = 18,
             AVAudioUnitDistortionPresetSpeechGoldenPi          = 19,
             AVAudioUnitDistortionPresetSpeechRadioTower        = 20,
             AVAudioUnitDistortionPresetSpeechWaves             = 21*/
            "Time": ["Speed Up", "Slow Down", "", "", ""]
        ]
        
        /* TODO: "Analyzer", // volume, pan, waveform visual, trim/edit capabilities
         "Equalizer", //  AVAudioUnitEQ, AVAudioUnitEQFilterType
         */
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
    
    
    //MARK: Recording output
    
    func setupNewSoundCollage(){
        
//        if isSpeakerEnabled == true {
//            setAudioPlaybackSource()
//        }
//        recordingEngine.stop()
//        recordingEngine.reset()
//        recordingEngine = AVAudioEngine()
//        
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//            
//            let ioBufferDuration = 128.0 / 44100.0
//            
//            try audioSession.setPreferredIOBufferDuration(ioBufferDuration)
//            
//        } catch {
//            
//            assertionFailure("AVAudioSession setup error: \(error)")
//        }
//        
//        let newPath = "newRecording"+".caf"
//        self.outputFileURL = getDocumentsDirectory().appendingPathComponent(newPath)
//        guard let outputFileURL = self.outputFileURL else { return }
//        print(outputFileURL)
//        do {
//            
//            try self.outputFile = AVAudioFile(forWriting: outputFileURL, settings: recordingEngine.mainMixerNode.outputFormat(forBus: 0).settings)
//        }
//        catch {
//            print("Error setting up audio file")
//        }
//        
//        let input = recordingEngine.inputNode!
//        let format = input.inputFormat(forBus: 0)
//        
//        recordingEngine.connect(input, to: recordingEngine.mainMixerNode, format: format)
//        assert(recordingEngine.inputNode != nil)
//        
//        try! recordingEngine.start()
//        //save url to property
    }
    
    
    func startRecordingSoundCollage() {
        
//        let mixer = recordingEngine.mainMixerNode
//        let format = mixer.outputFormat(forBus: 0)
//        
//        mixer.installTap(onBus: 0, bufferSize: 1024, format: format, block:
//            { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
//                
//                print(NSString(string: "writing"))
//                do{
//                    try self.outputFile.write(from: buffer)
//                }
//                catch {
//                    print(NSString(string: "Write failed"));
//                }
//        })
    }
    
    
    
    func stopRecordingSoundCollage() {
//
//        recordingEngine.mainMixerNode.removeTap(onBus: 0)
//        recordingEngine.stop()
//        setAudioPlaybackSource()
//        guard let url = self.outputFileURL else { return }
//        print("file recorded at \(String(describing: url.absoluteString))")
    }
    
    
    
}
