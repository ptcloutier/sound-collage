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
    
    var ouputMixer:                     AVAudioMixerNode?

    var recordedOutputFile: AVAudioFile?
    var audioFile: AVAudioFile!
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    var selectedSampleIndex: Int = 0
    var selectedSequencerIndex: Int = 0
    var audioRecorder: AVAudioRecorder!
    var audioFilePath: URL?
    var isRecordingModeEnabled = false
    var isSpeakerEnabled: Bool = false
    var isRecording: Bool = false
    var replaceableFilePath: String?
    var audioEngine: AVAudioEngine!
    var mixerPanels: [String : [String]] = [:]
    var effectControls: [[SCEffectControl]] = []
    var sequencerSettings: [[Bool]] = []
    var sequencerIsPlaying: Bool = false
    var audioBuffer = AVAudioPCMBuffer()
    var outputFile = AVAudioFile()
    var recordingEngine = AVAudioEngine()
    var isRecordingMixerOutput: Bool = false
    var outputFileURL: URL?
    var sampler: AVAudioUnitSampler?
    var audioController: SCGAudioController?
    var audioEngineChain: [AVAudioEngine] = []
    var finishedEngines: [AVAudioEngine] = []
     
    
    
    func setupAudioManager(){
        
        setupEffects()
                
/*
         NotificationCenter.default.addObserver( self, selector: #selector(routeChanged), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
*/
        
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
        
        guard let sampleBank = SCDataManager.shared.user?.currentSampleBank else {
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


    
    
    
    func getPathForSampleIndex(sampleIndex: Int) -> String? {
        
        guard let partialPath = getSample(selectedSampleIndex: sampleIndex) else {
            print("Playback sample not found")
            return nil
        }
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as String
        let fullPath = docsDirectory.appending("/\(partialPath)")
        
        return fullPath
    }
    
    
    
    func getAudioFileForPath(path: String) { // -> AVAudioFile? {
        
        /*
        let url = URL.init(fileURLWithPath: path )
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            return audioFile
        } catch let error {
            print("Could not play sound file. \(error.localizedDescription)")
            return nil
        } */
    }

    

    
    func playAudio(sampleIndex: Int){ // self.audioController.startRecording(), self.audioController.stopRecording()
        
        /*
        // audioManager multiple engines
        removeUsedEngines()
        self.audioEngine = SCAudioEngine()
        self.audioEngineChain.append(self.audioEngine)
        */
        
        guard let path = getPathForSampleIndex(sampleIndex: sampleIndex) else { return }
        let url = URL.init(fileURLWithPath: path)
        self.audioController?.playSample(sampleURL: url)
        /*
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
        print("Playing audiofile at \(path)") */
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
    
    
//    
//    
//    
//    func setupReverb(sampleIndex: Int) -> AVAudioUnitReverb {
//        
//        let reverb = AVAudioUnitReverb()
//        let reverbParams = effectControls[0]
//       
//        if let reverbValue: Float = Float(String(format: "%.0f", reverbParams[0].parameter[sampleIndex]*100.0)) {
//            reverb.loadFactoryPreset(.plate) // there are thirteen possible presets
//            reverb.wetDryMix = reverbValue
//        }
//        return reverb
//    }
//    
//    
//    
//    
//    func setupDelay(sampleIndex: Int) -> AVAudioUnitDelay {
//        
//        let delay = AVAudioUnitDelay()
//        let delayParams = effectControls[1]
//        
//        let delayWetDryMixValue = delayParams[0].parameter[sampleIndex] * 100.0
//        delay.wetDryMix = delayWetDryMixValue
//        
//        let delayTime = delayParams[1].parameter[sampleIndex]
//        delay.delayTime = TimeInterval(delayTime)
//        
//        let delayFeedback = delayParams[2].parameter[sampleIndex] * 80.0
//        delay.feedback = delayFeedback
//        
//        let delayLPCutoff = delayParams[3].parameter[sampleIndex] * 6000.0 // 10 -> (samplerate/2), default 15000
//        delay.lowPassCutoff = delayLPCutoff
//       
//        return delay
//    }
//    
//    
//    
//    func setupPitchShift(sampleIndex: Int) -> AVAudioUnitTimePitch {
//        
//        let pitch = AVAudioUnitTimePitch()
//        let pitchParams = effectControls[2]
//        
//        let pitchUp = pitchParams[0].parameter[sampleIndex] * 100.0
//        let pitchUpValue = pitchUp * 24.0
//        let posiPitch = pitchUpValue+1.0
//       
//        let pitchDown = pitchParams[1].parameter[sampleIndex] * 100.0
//        let pitchDownValue = pitchDown * 24.0
//        let negiPitch = (pitchDownValue+1.0) * -1.0
//        
//        pitch.pitch = posiPitch + negiPitch
//       
//        return pitch
//    }
//    
//    
//    
//    func setupDistortion(sampleIndex: Int) -> AVAudioUnitDistortion {
//        
//        let distortion = AVAudioUnitDistortion()
//        let distortionParams = effectControls[4]
//        
//        let preGainValue = distortionParams[0].parameter[sampleIndex] * 100.0// range -80.0 -> 20.0
//        distortion.preGain = Float(preGainValue - 80.0)
//       
//        let dmix = distortionParams[1].parameter[sampleIndex] * 100.0
//        distortion.wetDryMix = dmix
//       
//        return distortion
//    }
//    
//    
//    
//    
//    func setupTimeStretch(sampleIndex: Int) -> AVAudioUnitVarispeed {
//        
//        let time = AVAudioUnitVarispeed()
//        let timeParams = effectControls[3]
//        
//        let timeRateUp = 1.0 + timeParams[0].parameter[sampleIndex] * 4.0
//        let timeRateDown = timeParams[1].parameter[sampleIndex] * 0.75
//     
//        let rateValue = Float(timeRateUp - timeRateDown)
//        time.rate = rateValue
//        
//        return time
//    }
//    
//    
//    /* //MARK: TODO: EQ 
//     func setupEQ() ->eq {
//     var EQNode:AVAudioUnitEQ!
//     
//     EQNode = AVAudioUnitEQ(numberOfBands: 2)
//     engine.attach(EQNode)
//     
//     var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
//     filterParams.filterType = .highPass
//     filterParams.frequency = 80.0
//     
//     filterParams = EQNode.bands[1] as AVAudioUnitEQFilterParameters
//     filterParams.filterType = .parametric
//     filterParams.frequency = 500.0
//     filterParams.bandwidth = 2.0
//     filterParams.gain = 4.0
//     
//     let format = mixer.outputFormat(forBus: 0)
//     engine.connect(playerNode, to: EQNode, format: format )
//     engine.connect(EQNode, to: engine.mainMixerNode, format: format)
//     }
//     */
//    
    
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
    
        isRecording = true
        setupNewSample()
        startRecordingSample()
    }
    
    

    
    
    
    private func getSampleID(samplePadIndex: Int) -> Int {
        
        let userDefaults = UserDefaults.standard
        
        guard let id = userDefaults.value(forKey: "samplePad_\(samplePadIndex)_sampleID") else {
            userDefaults.set(0, forKey: "samplePad_\(samplePadIndex)_sampleID")
            return 0
        }
        let sampleID = id as! Int
        userDefaults.set(sampleID+1, forKey: "samplePad_\(samplePadIndex)_sampleID")
        return sampleID+1
    }
    
    

    
    
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
    
    func setupNewSample(){
        
        if isSpeakerEnabled == true {
            isSpeakerEnabled = false
            setAudioPlaybackSource()
        }
        recordingEngine.stop()
        recordingEngine.reset()
        recordingEngine = AVAudioEngine()
        
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.setupAudioFileForSample()
                    } else {
                        print("Failed to record!")
                    }
                }
            }
        } catch {
            print("Failed to record!")
        }
    }

    
    
    
    func setupAudioFileForSample(){
        
        guard let id = SCDataManager.shared.user?.currentSampleBank?.id else {
            print("current sample bank id not found.")
            return
        }
        
        let sampleID = getSampleID(samplePadIndex: selectedSampleIndex)
        let audioType = ".aac"
        let filePath = "sampleBank_\(id)_pad_\(selectedSampleIndex)_id_\(sampleID)\(audioType)"
        let fullURL = getDocumentsDirectory().appendingPathComponent(filePath)
        SCDataManager.shared.currentSampleTitle = fullURL.absoluteString
        self.replaceableFilePath = "sampleBank_\(id)_pad_\(selectedSampleIndex)_id_\(sampleID-1)\(audioType)"
        self.audioFilePath = fullURL
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ] as [String : Any]
        
        do {
            
            try self.audioFile = AVAudioFile(forWriting: fullURL, settings: settings)
        }
        catch {
            print("Error setting up audio file")
        }
    }
    
    
    
    
    func startRecordingSample() {
        
        
        let input = recordingEngine.inputNode!
        let inputFormat = input.inputFormat(forBus: 0)
        
        recordingEngine.connect(input, to: recordingEngine.mainMixerNode, format: inputFormat)
        assert(recordingEngine.inputNode != nil)
        
        try! recordingEngine.start()
        //save url to property
        
        isRecording = true
        let mixer = recordingEngine.mainMixerNode
        let outputFormat = mixer.outputFormat(forBus: 0)
        
        mixer.installTap(onBus: 0, bufferSize: 1024, format: outputFormat, block:
            { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                
                print(NSString(string: "writing"))
                do {
                    try self.audioFile.write(from: buffer)
                }
                catch {
                    print(NSString(string: "Write failed"));
                }
        })
    }
    
    
    
    func stopRecordingSample() {

        recordingEngine.mainMixerNode.removeTap(onBus: 0)   
        recordingEngine.stop()
        isRecording = false
        print("Audio recording stopped.")
        
        setAudioPlaybackSource()
        guard let url = self.audioFilePath else { return }
        self.postRecordingFinishedNotification()
        
        let urlPart = url.lastPathComponent
        guard let sampleBank = SCDataManager.shared.user?.currentSampleBank else { return }
        
        for key in sampleBank.samples.keys{
            if key == selectedSampleIndex.description {
                sampleBank.samples[key] = urlPart as AnyObject?
                print("Audio file recorded and saved at \(urlPart.description)")
            }
        }
        SCDataManager.shared.user?.currentSampleBank? = sampleBank
        isRecordingModeEnabled = false
        SCDataManager.shared.saveObjectToJSON()

        print("file recorded at \(String(describing: url.absoluteString))")
        observeAudioIO()
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
    
    
        
}
