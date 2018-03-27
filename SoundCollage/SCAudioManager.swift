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
        
        var isSetup: Bool?
        var recordedOutputFile: AVAudioFile?
        var audioFile: AVAudioFile!
        let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
        var selectedSampleIndex: Int = 0
        var selectedSequencerIndex: Int = 0
        var audioRecorder: AVAudioRecorder!
        var audioFilePath: URL?
        var isRecordingModeEnabled = false
        var isSpeakerEnabled: Bool = false
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
        var audioEngineChain: [AVAudioEngine] = []
        var finishedEngines: [AVAudioEngine] = []
        // scg
        var songPlayer: AVAudioPlayer?
        var activePlayers: Int = 0
        let maxPlayers: Int = 25
        var plays: Int = 0
        var finishedNodes: [AVAudioNode] = []
        var nodeChain: [AnyObject] = []
        var audioFiles: [String : Any?] = [:]
        //    var effectControls: [[SCEffectControl]] = []
        var engine: AVAudioEngine?
        var mixer: AVAudioMixerNode?
        //    var sampler: AVAudioUnitSampler?
        var nodeIdx: Int = 0
        var player:                         AVAudioPlayerNode?
        var reverb:                         AVAudioUnitReverb?
        var distortion:                     AVAudioUnitDistortion?
        var delay:                          AVAudioUnitDelay?
        var pitchShift:                     AVAudioUnitTimePitch?
        var timeStretch:                    AVAudioUnitVarispeed?
        var mixerOutputFile:                AVAudioFile!
        var recordingIsAvailable:           Bool = false
        var playerIsPlaying:                Bool = false
        var playerVolume:                   Float? // 0.0 - 1.0
        var playerPan:                      Float? // -1.0 - 1.0
        var samplerDirectVolume:            Float? // 0.0 - 1.0
        var samplerEffectVolume:            Float? // 0.0 - 1.0
        var distortionWetDryMix:            Float? // 0.0 - 1.0
        var distortionPreset:               Int?
        var reverbWetDryMix:                Float?  // 0.0 - 1.0
        var reverbPreset:                   Int?
        var outputVolume:                   Float?  // 0.0 - 1.0
         // buffer for the player
        var playerLoopBuffer:               AVAudioPCMBuffer?
        // for the node tap
        var mixerOutputFileURL:             URL?
        var isRecording:                    Bool = false
        var isRecordingSelected:            Bool = false
        // managing session and configuration changes
        var isSessionInterrupted:           Bool = false
        var isConfigChangePending:          Bool = false
        
        //MARK: Set up session
        
        func setupAudioManager(){
            setupEffects()
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
            self.mixerOutputFileURL = nil
            self.isSessionInterrupted = false
            self.isConfigChangePending = false
            effectControls = SCAudioManager.shared.effectControls
            initAVAudioSession()
            loadSamples()
            engine = AVAudioEngine.init()
            isRecording = false
            isRecordingSelected = false
            print("\(String(describing: engine?.description))")
            NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ShouldEnginePauseNotification"),
                                                   object: nil,
                                                   queue: OperationQueue.main,
                                                   using: {
                                                    note in
                                                    if !self.isSessionInterrupted && !self.isConfigChangePending {
                                                        if self.playerIsPlaying == true || self.isRecording == true {
                                                            print("Pausing engine.")
                                                            self.engine?.pause()
                                                            self.engine?.reset()
                                                        }
                                                    }
            })
        }
        
        //MARK: Playback
        
        func getSample(selectedSampleIndex: Int) -> String? {
            var selectedSample: String?
            let dm = SCDataManager.shared
            guard let sampleBank = dm.user?.sampleBanks[dm.currentSampleBank!] else {
                print("Error retrieving sampleBank for playback")
                return nil
            }
            for key in sampleBank.samples.keys {
                if key == selectedSampleIndex.description {
                    selectedSample = sampleBank.samples[key]
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
        
        func getIndex(senderID: Int)-> Int?{
            var sampleIdx: Int?
            switch senderID {
            case 0:
                sampleIdx = SCAudioManager.shared.selectedSampleIndex
            case 1:
                sampleIdx = SCAudioManager.shared.selectedSequencerIndex
            default:
                print("Error, no index.")
                return nil
            }
            return sampleIdx
        }
        
        //MARK: Effects
        
        private func setupEffects(){
            self.mixerPanels = ["Reverb" : ["Mix", "", "", "", ""],
                                "Delay" : ["Mix", "Delay Time", "Feedback", "Cutoff", ""],
                                "Pitch" : ["Pitch Up", "Pitch Down", "", "", ""],
                                "Distortion" : ["Mix", "Gain", "", "", ""],
                                "Time": ["Speed Up", "Slow Down", "", "", ""]
            ]
        }
        
        func effectsParametersDidChange(values: [Int], sliderValue: Float) {
            let mixerPanelIdx = Int(values[0])
            let sliderIdx = Int(values[1])
            let selectedSamplePad = Int(values[2])
            let dm = SCDataManager.shared
            self.effectControls[mixerPanelIdx][sliderIdx].parameter[selectedSamplePad] = sliderValue
            dm.user?.sampleBanks[dm.currentSampleBank!].effectSettings = self.effectControls
            SCDataManager.shared.saveObjectToJSON() // write to file
            
            switch mixerPanelIdx {
            case 0:
                print("reverb changed")
                break
            case 1:
                print("delay changed")
                break
            case 2:
                print("pitch changed")
                break
            case 3:
                print("time changed")
                break
            case 4:
                print("distortion changed ")
                break
            default:
                print("default .... ")
                break
            }
        }
        
        //MARK: Record samples
        
        func recordNew() {
            isRecording = true
            setupNewSample()
            startRecordingSample()
        }
        
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
            guard let id = SCDataManager.shared.currentSampleBank else {
                print("current sample bank id not found.")
                return
            }
            let sampleID = getSampleID(samplePadIndex: selectedSampleIndex)
            let audioType = ".caf"
            let filePath = "sampleBank_\(id)_pad_\(selectedSampleIndex)_id_\(sampleID)\(audioType)"
            let fullURL = getDocumentsDirectory().appendingPathComponent(filePath)
            SCDataManager.shared.currentSamplePath = fullURL.absoluteString
            self.replaceableFilePath = "sampleBank_\(id)_pad_\(selectedSampleIndex)_id_\(sampleID-1)\(audioType)"
            self.audioFilePath = fullURL
            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleIMA4),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVLinearPCMBitDepthKey: Int(32),
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                ] as [String : Any]
            do {
                try self.audioFile = AVAudioFile(forWriting: fullURL, settings: settings)
            }
            catch {
                print("Error setting up audio file")
            }
        }
        
        func startRecordingSample() {
            let input = recordingEngine.inputNode
            let inputFormat = input.inputFormat(forBus: 0)
            recordingEngine.connect(input, to: recordingEngine.mainMixerNode, format: inputFormat)
            try! recordingEngine.start()
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
            for key in (SCDataManager.shared.user?.sampleBanks[SCDataManager.shared.currentSampleBank!].samples.keys)!{
                if key == selectedSampleIndex.description {
                    SCDataManager.shared.user?.sampleBanks[SCDataManager.shared.currentSampleBank!].samples[key] = urlPart
                    print("Audio file recorded and saved at \(urlPart.description)")
                    break
                }
            }
            SCAudioManager.shared.getAudioFilesForURL()
            isRecordingModeEnabled = false
            SCDataManager.shared.saveObjectToJSON()
            observeAudioIO()
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
        
        func getDocumentsDirectory() -> URL {
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
        
        
        private func createEngine(){
            engine = nil
            engine = AVAudioEngine.init()
            print("\(String(describing: engine?.description))")
        }
        
        private func startEngine(){
            if (engine?.isRunning)! == true {
                print("audio engine already started ")
                return
            }
            do {
                try engine?.start()
                print("audio engine started")
            } catch {
                print("oops \(error)")
                print("could not start audio engine")
            }
        }
        
        //MARK: AVAudioMixinDestination Methods
        
        func loadSamples() {
            if let urls: [URL] = Bundle.main.urls(forResourcesWithExtension: "aac", subdirectory: "Documents") {
                do {
                    try sampler?.loadAudioFiles(at: urls)
                } catch {
                    print("No sample\n")
                }
            }
        }
        
        
        
        //MARK: Mixer Methods //TODO: is this ncesary?
        
        private func setOutputVolume(outputVolume: Float){
            engine?.mainMixerNode.outputVolume = outputVolume
        }
        
        //MARK: Effect Methods
        
        func setupReverb(sampleIndex: Int, reverb: AVAudioUnitReverb) {
            let reverbParams = effectControls[0]
            if let reverbValue: Float = Float(String(format: "%.0f", reverbParams[0].parameter[sampleIndex]*50.0)) {
                self.reverbWetDryMix = reverbValue
                reverb.loadFactoryPreset(.cathedral) // there are thirteen possible presets
                reverb.wetDryMix = self.reverbWetDryMix!
            }
        }
        
        func setupDelay(sampleIndex: Int, delay: AVAudioUnitDelay) {
            let delayParams = effectControls[1]
            let delayWetDryMixValue = delayParams[0].parameter[sampleIndex] * 100.0
            delay.wetDryMix = delayWetDryMixValue
            let delayTime = delayParams[1].parameter[sampleIndex] * 0.5
            delay.delayTime = TimeInterval(delayTime)
            let delayFeedback = delayParams[2].parameter[sampleIndex] * 70.0
            delay.feedback = delayFeedback
            let delayLPCutoff = delayParams[3].parameter[sampleIndex] * 6000.0 // 10 -> (samplerate/2), default 15000
            delay.lowPassCutoff = delayLPCutoff
        }
        
        func setupPitchShift(sampleIndex: Int, pitch: AVAudioUnitTimePitch) {
            let pitchParams = effectControls[2]
            let pitchUp = pitchParams[0].parameter[sampleIndex] * 100.0
            let pitchUpValue = pitchUp * 24.0
            let posiPitch = pitchUpValue+1.0
            let pitchDown = pitchParams[1].parameter[sampleIndex] * 100.0
            let pitchDownValue = pitchDown * 24.0
            let negiPitch = (pitchDownValue+1.0) * -1.0
            pitch.pitch = posiPitch + negiPitch
        }
        
        func setupDistortion(sampleIndex: Int, distortion: AVAudioUnitDistortion) {
            let distortionParams = effectControls[4]
            let preGainValue = distortionParams[0].parameter[sampleIndex] * 100.0// range -80.0 -> 20.0
            distortion.preGain = Float(preGainValue - 80.0)
            let dmix = distortionParams[1].parameter[sampleIndex] * 100.0
            distortion.wetDryMix = dmix
        }
        
        func setupTimeStretch(sampleIndex: Int, time: AVAudioUnitVarispeed) {
            let timeParams = effectControls[3]
            let timeRateUp = 1.0 + timeParams[0].parameter[sampleIndex] * 4.0
            let timeRateDown = timeParams[1].parameter[sampleIndex] * 0.75
            let rateValue = Float(timeRateUp - timeRateDown)
            time.rate = rateValue
        }
        
        private func setDistortionWetDryMix(distortionWetDryMix: Float){
            distortion?.wetDryMix = distortionWetDryMix * 100.0
        }
        
        private func setDistortionPreset(distortionPreset: Int) {
            if distortion != nil {
                distortion?.loadFactoryPreset(AVAudioUnitDistortionPreset(rawValue: distortionPreset)!)
            }
        }
        
        func setReverbWetDryMix(reverbWetDryMix: Float) {
            reverb?.wetDryMix = reverbWetDryMix// * 100.0
        }
        
        private func setReverbPreset(reverbPreset: Int){
            if reverb != nil {
                reverb?.loadFactoryPreset(AVAudioUnitReverbPreset(rawValue: reverbPreset)!)
            }
        }
        
        //MARK: Player Methods
        
        private func setPlayerVolume(playerVolume: Float) {
            player?.volume = playerVolume
        }
        
        
        private func setPlayerPan(playerPan: Float){
            player?.pan = playerPan
        }
        
        func togglePlayer(index: Int){
            let mixer = AVAudioMixerNode.init()
            engine?.attach(mixer)
            let playerFormat = AVAudioFormat.init(standardFormatWithSampleRate: 44100, channels: 1)
            let mainMixer = (engine?.mainMixerNode)!
            let sampler = AVAudioUnitSampler.init()
            engine?.attach(sampler)
            let player = AVAudioPlayerNode.init()
            engine?.attach(player)
            let reverb = AVAudioUnitReverb()
            let delay = AVAudioUnitDelay()
            let pitchShift = AVAudioUnitTimePitch()
            let distortion = AVAudioUnitDistortion()
            let timeStretch = AVAudioUnitVarispeed()
            setupReverb(sampleIndex: index, reverb: reverb)
            setupDelay(sampleIndex: index, delay: delay)
            setupPitchShift(sampleIndex: index, pitch: pitchShift)
            setupTimeStretch(sampleIndex: index, time: timeStretch)
            setupDistortion(sampleIndex: index, distortion: distortion)
            engine?.attach(reverb)
            engine?.attach(delay)
            engine?.attach(pitchShift)
            engine?.attach(timeStretch)
            engine?.attach(distortion)
            engine?.connect(player, to: mixer, format: playerFormat)
            engine?.connect(mixer, to: pitchShift, format: playerFormat)
            engine?.connect(pitchShift, to: timeStretch, format: playerFormat)
            engine?.connect(timeStretch, to: distortion, format: playerFormat)
            engine?.connect(distortion, to: delay, format: playerFormat)
            engine?.connect(delay, to: reverb, format: playerFormat)
            engine?.connect(reverb, to: mainMixer, format: playerFormat)
            var disconnectNodes = [player, sampler, reverb, delay, pitchShift, timeStretch, distortion]
            startEngine()
            let key: String = "\(index)"
            guard let sample: AVAudioFile = audioFiles[key]! as? AVAudioFile else {
                print("No sample at selected sample index!")
                return
            }
            playerIsPlaying = true
            plays = plays+1
            activePlayers = activePlayers+1
            print("total plays : \(plays), active players: \(activePlayers)")
            player.scheduleFile(sample, at: nil, completionHandler: {
                [weak self] in
                guard let strongSelf = self else { return }
                //calculate audio tail based on reverb and delay parameters
                var durationValue = Int(round(Double(sample.length)/44100))
                if durationValue == 0 {
                    durationValue = 1
                }
                let reverbParameter = SCAudioManager.shared.effectControls[0][0].parameter[index]
                let reverbTime = round(Float(reverbParameter * 5.0))
                durationValue += Int(reverbTime)
                let delayParams = SCAudioManager.shared.effectControls[1][2].parameter[index]
                let delayTime = round(Float(delayParams * 5.0))
                durationValue += Int(delayTime)
                durationValue = durationValue+1
                let duration = DispatchTimeInterval.seconds(durationValue)
                let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
                delayQueue.asyncAfter(deadline: .now()+duration){
                    let serialQueue = DispatchQueue(label: "myqueue")
                    serialQueue.sync {
                        DispatchQueue.main.async {
                            for x in disconnectNodes {
                                strongSelf.engine?.disconnectNodeInput(x)
                            }
                            for i in disconnectNodes {
                                strongSelf.engine?.detach(i)
                            }
                            disconnectNodes.removeAll()
                            strongSelf.playerIsPlaying = false
                            strongSelf.activePlayers = strongSelf.activePlayers-1
                            print("total plays : \(strongSelf.plays), active players: \(strongSelf.activePlayers)")
                        }
                    }
                }
            })
            player.play()
        }
        
        private func createAudioFileForPlayback() -> AVAudioFile? {
            var recording: AVAudioFile
            do {
                recording = try AVAudioFile.init(forReading: mixerOutputFileURL!)
                return recording
            } catch let error {
                print("couldn't create AVAudioFile, \(error.localizedDescription)")
                return nil
            }
        }
        
        //MARK: Multiple players
        
        func getSample(samplePath: String) -> AVAudioFile? {
            do {
                let url = URL.init(string: samplePath)
                let sample = try AVAudioFile.init(forReading: url!)
                return sample
            } catch {
                return nil
            }
        }
        
        func getAudioFilesForURL(){
            let dm = SCDataManager.shared
            if dm.currentSampleBank == nil {
                dm.currentSampleBank = dm.getLastSampleBankIdx()
            }
            guard let currentSB = dm.user?.sampleBanks[dm.currentSampleBank!]  else {
                print("Error, no current sample bank.")
                return
            }
            audioFiles = currentSB.samples
            for (key, value) in audioFiles {
                let path = SCAudioManager.shared.getPathForSampleIndex(sampleIndex: Int(key)!)
                if let audioFile: AVAudioFile = getSample(samplePath: path!) {
                    audioFiles.updateValue(audioFile, forKey: key)
                    print("AudioFiles key : \(key), val : \(String(describing: value))")
                }
            }
        }
        
        //MARK: Recording Methods
        
        func startRecordingMixerOutput(){
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                if mixerOutputFileURL == nil {
                    let id = getSoundCollageID()
                    let filePath = "sound_collage_"+"\(id)"+".aac"
                    mixerOutputFileURL = SCAudioManager.shared.getDocumentsDirectory().appendingPathComponent(filePath)
                }
                let mainMixer = engine?.mainMixerNode
                let settings  = [AVSampleRateKey: 44100,
                                 AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                 AVNumberOfChannelsKey: 2,
                                 AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
                let format: AVAudioFormat = AVAudioFormat.init(settings: settings)!
                do {
                    mixerOutputFile = try AVAudioFile.init(forWriting: mixerOutputFileURL!, settings: format.settings)
                } catch let error {
                    print("mixerOutputFile is nil, \(error.localizedDescription)")
                }
                mainMixer?.installTap(onBus: 0, bufferSize: 4096, format: mainMixer?.outputFormat(forBus: 0), block:  {
                    (buffer : AVAudioPCMBuffer!, when : AVAudioTime!) in
                    print("Got buffer of length: \(buffer.frameLength) at time: \(when)")
                    do {
                        try self.mixerOutputFile.write(from: buffer)
                    } catch {
                        print("error \(error.localizedDescription)")
                    }
                })
                print("starting audio engine for recording")
                print("writing to \(String(describing: self.mixerOutputFileURL?.absoluteString))")
                do {
                    try self.engine?.start()
                } catch {
                    print("Error starting audio engine: \(error.localizedDescription)")
                }
                self.isRecording = true
            } catch let error {
                print("Error setting avaudiosession category, \(error.localizedDescription)")
            }
        }
        
        private func getSoundCollageID() -> Int {
            let userDefaults = UserDefaults.standard
            guard let id = userDefaults.value(forKey: "sound_collage_id") else {
                userDefaults.set(0, forKey: "sound_collage_id")
                return 0
            }
            let scID = id as! Int
            userDefaults.set(scID+1, forKey: "sound_collage_id")
            return scID+1
        }
        
        func stopRecordingMixerOutput(){
            guard let path = self.mixerOutputFileURL?.lastPathComponent else { return }
            print("Recorded output to \(path)")
            SCDataManager.shared.user?.soundCollages.append(path)
            if isRecording == true {
                engine?.mainMixerNode.removeTap(onBus: 0)
                isRecording = false
                if recordingIsAvailable == true {
                    //Post a notification that recording is complete
                    // Other nodes/objects can listen to this update
                    NotificationCenter.default.post(name: SCConstants.ShouldEnginePauseNotification, object: nil)
                }
            }
        }
        
        func stopSong(){
            if SCDataManager.shared.user?.soundCollages.count == 0 {
                print("No songs recorded yet to sound collages.")
                return
            }
            if songPlayer != nil {
                if (songPlayer?.isPlaying)! {
                    print("stop song.")
                    songPlayer?.stop()
                    return
                }
            }
        }
        
        func playSoundCollage(index: Int){
            if SCDataManager.shared.user?.soundCollages.count == 0 {
                print("No songs recorded yet to sound collages.")
                return
            }
            if songPlayer != nil {
                if (songPlayer?.isPlaying)! {
                    print("stop song.")
                    songPlayer?.stop()
                    return
                }
            }
            guard let filePath = SCDataManager.shared.user?.soundCollages[index] else { return }
            let url = SCAudioManager.shared.getDocumentsDirectory().appendingPathComponent(filePath)
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
            do {
                songPlayer = try AVAudioPlayer(contentsOf: url)
                songPlayer?.prepareToPlay()
                songPlayer?.play()
            } catch let error {
                print("\(error.localizedDescription)")
            }
        }
        
        //MARK: AVAudioSession
        
        func initAVAudioSession(){
            let sessionInstance = AVAudioSession.sharedInstance()
            do {
                try sessionInstance.setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("Error setting AVAudioSession category, \(error.localizedDescription)")
            }
            let hwSampleRate: Double = 44100
            do {
                try sessionInstance.setPreferredSampleRate(hwSampleRate)
            } catch let error {
                print("Error setting preferred sample rate!, \(error.localizedDescription)")
            }
            let ioBufferDuration: TimeInterval = 0.0029
            do {
                try sessionInstance.setPreferredIOBufferDuration(ioBufferDuration)
            } catch let error {
                print("Error setting preferred io buffer duration! \(error.localizedDescription)")
            }
            // add interruption handler
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(handleInterruption(notification:)), name: NSNotification.Name.AVAudioSessionInterruption, object: sessionInstance)
            nc.addObserver(self, selector: #selector(handleRouteChange(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: sessionInstance)
            nc.addObserver(self, selector: #selector(handleMediaServicesReset(notification:)), name: NSNotification.Name.AVAudioSessionMediaServicesWereReset, object: sessionInstance)
            // activate the audio session
            do {
                try sessionInstance.setActive(true)
            } catch let error {
                print("Error setting session active!, \(error.localizedDescription)")
            }
        }
        
        @objc func handleInterruption(notification: NSNotification) {
            guard let userInfo = notification.userInfo,
                let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeRawValue) else {
                    return
            }
            if interruptionType == .began {
                print("Session interrupted > --- Begin Interruption ---\n")
                isSessionInterrupted = true
                player?.stop()
                stopRecordingMixerOutput()
            }
            if interruptionType == .ended {
                print("Session interrupted > --- End Interruption ---\n")
                // make sure to activate the session
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    isSessionInterrupted = false
                    if isConfigChangePending == true {
                        // there is a pending config changed notification
                        isConfigChangePending = false
                        startEngine()
                    }
                } catch let error {
                    print("AVAudioSession set active failed with error, \(error.localizedDescription)")
                }
            }
        }
        
        @objc func handleRouteChange(notification: NSNotification) {
            guard let userInfo = notification.userInfo,
                let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else {
                    return
            }
            print("Route change:")
            switch reason {
            case .unknown:
                print("     Unknown")
                break
            case .newDeviceAvailable:
                print("     NewDeviceAvailable")
                SCAudioManager.shared.observeAudioIO()
                break
            case .oldDeviceUnavailable:
                print("     OldDeviceUnavailable")
                SCAudioManager.shared.observeAudioIO()
                break
            case .categoryChange:
                print("     CategoryChange")
                print("     New Category: \(AVAudioSession.sharedInstance().category)")
                break
            case .override:
                print("     Override")
                break
            case .wakeFromSleep:
                print("     WakeFromSleep")
                break
            case .noSuitableRouteForCategory:
                print("     NoSuitableRouteForCategory")
                break
            default:
                print("     ReasonUnknown")
            }
        }
        
        @objc func handleMediaServicesReset(notification: NSNotification) {
            // if we've received this notification, the media server has been reset
            // re-wire all the connections and start the engine
            print("Media services have been reset!")
            print("Re-wiring connections")
            // Re-configure the audio session per QA1749
            let sessionInstance = AVAudioSession.sharedInstance()
            // set the session category
            do {
                try sessionInstance.setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
                print("Error setting AVAudioSession category after media services reset \(error.localizedDescription)")
            }
            // set the session active
            do {
                try sessionInstance.setActive(true)
            } catch let error {
                print("Error activating AVAudioSession after media services reset \(error.localizedDescription)")
            }
            createEngine()
        }
    }
