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
    
    func setupAudioManager(){
        
        
       setupEffects()
        
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
         "Time", AVAudioUnitTimeEffect
         "Speed" AVAudioUnitVarispeed */
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
        
//        removeUsedEngines()
        
        self.audioEngine = SCAudioEngine()
        self.audioEngineChain.append(self.audioEngine)
        
        
        do {
            let audioFile = try AVAudioFile(forReading: fullURL)
            let audioFormat = audioFile.processingFormat
            let audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attach(audioPlayerNode)
            
            // selected effect in effectControl, selectedSamplePad parameter in parameter
            
            let effectSettings = self.effectControls
            let reverb = AVAudioUnitReverb()
            let reverbParams = effectSettings[0]
            if let reverbValue: Float = Float(String(format: "%.0f", reverbParams[0].parameter[selectedSampleIndex]*100.0)) {
                reverb.loadFactoryPreset(.plate) // there are thirteen posible presets
                reverb.wetDryMix = reverbValue
            }
            audioEngine.attach(reverb)
            
            
            
            let delay = AVAudioUnitDelay()
            let delayParams = effectSettings[1]
            let delayWetDryMixValue = delayParams[0].parameter[selectedSampleIndex] * 100.0
            delay.wetDryMix = delayWetDryMixValue
            
            
            let delayTime = delayParams[1].parameter[selectedSampleIndex]
            delay.delayTime = TimeInterval(delayTime)
            
            
            let delayFeedback = delayParams[2].parameter[selectedSampleIndex] * 80.0
            
            delay.feedback = delayFeedback
            
            
            let delayLPCutoff = delayParams[3].parameter[selectedSampleIndex] * 6000.0 // 10 -> (samplerate/2), default 15000
            delay.lowPassCutoff = delayLPCutoff
           
            audioEngine.attach(delay)
            
            
            let pitch = AVAudioUnitTimePitch()
            let pitchParams = effectSettings[2]
            let pitchUp = pitchParams[0].parameter[selectedSampleIndex] * 100.0
            let pitchUpValue = pitchUp * 24.0
            let posiPitch = pitchUpValue+1.0
            
            
            let pitchDown = pitchParams[1].parameter[selectedSampleIndex] * 100.0
            let pitchDownValue = pitchDown * 24.0
            let negiPitch = (pitchDownValue+1.0) * -1.0
            pitch.pitch = posiPitch + negiPitch

            audioEngine.attach(pitch)
            
            
            
            let distortion = AVAudioUnitDistortion()
            let distortionParams = effectSettings[4]
            let preGainValue = distortionParams[0].parameter[selectedSampleIndex] * 100.0// range -80.0 -> 20.0
            distortion.preGain = Float(preGainValue - 80.0)
            let dmix = distortionParams[1].parameter[selectedSampleIndex] * 100.0
            distortion.wetDryMix = dmix
            audioEngine.attach(distortion)

            
            
            let time = AVAudioUnitVarispeed()
            let timeParams = effectSettings[3]
            let timeRateUp = 1.0 + timeParams[0].parameter[selectedSampleIndex] * 4.0
            let timeRateDown = timeParams[1].parameter[selectedSampleIndex] * 0.75
            
            let rateValue = Float(timeRateUp - timeRateDown)
            time.rate = rateValue
            audioEngine.attach(time)
            
//            sampler = AVAudioUnitSampler()
//            audioEngine.attach(sampler)
//            let stereoFormat: AVAudioFormat
            
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
                
                //TODO: calculate effect tail for engine destruction
                let reverbParameter = strongSelf.effectControls[0][0].parameter[strongSelf.selectedSampleIndex]
                let reverbTime = round(Float(reverbParameter * 10.0))
                durationInt += Int(reverbTime)
                
                let delayParams = strongSelf.effectControls[1][2].parameter[strongSelf.selectedSampleIndex]
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
            print("Playing audiofile at \(fullURL.absoluteString)")
        } catch let error {
            print("Could not play sound file! \(error.localizedDescription)")
        }
    }
    
    
    
    func effectsParametersDidChange(values: [Int], sliderValue: Float) {
        
        let mixerPanelIdx = Int(values[0])
        let sliderIdx = Int(values[1])
        let selectedSamplePad = Int(values[2])
 
//        SCDataManager.shared.user?.currentSampleBank?.effectSettings[mixerPanelIdx][sliderIdx].parameter[selectedSamplePad] = sliderValue
        
        self.effectControls[mixerPanelIdx][sliderIdx].parameter[selectedSamplePad] = sliderValue
        SCDataManager.shared.user?.currentSampleBank?.effectSettings = self.effectControls
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
