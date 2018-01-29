//
//  SCGAudioController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/6/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
/*
 
 Abstract:
 SCGAudioController is the main controller class that creates the following objects:
 AVAudioEngine               *engine;
 AVAudioUnitSampler          *_sampler;
 AVAudioUnitDistortion       *_distortion;
 AVAudioUnitReverb           *_reverb;
 AVAudioPlayerNode           *_player;
 
 AVAudioSequencer            *_sequencer;
 AVAudioPCMBuffer            *_playerLoopBuffer;
 
 It connects all the nodes, loads the buffers as well as controls the AVAudioEngine object itself.
 */

import Foundation
import AVFoundation

// Other nodes/objects can listen to this to determine when the user finishes a recording



protocol SCGAudioControllerDelegate: class {
    
    func engineWasInterrupted()
    func engineConfigurationHasChanged()
    func engineHasBeenPaused()
    func mixerOutputFilePlayerHasStopped()
}


class SCGAudioController {
    
    var songPlayer:                     AVAudioPlayer?
    var activePlayers:                  Int = 0
    let maxPlayers:                     Int = 25
    var plays:                          Int = 0
    var finishedNodes:                  [AVAudioNode] = []
    var nodeChain:                      [AnyObject] = []
    var audioFiles:                     [String : Any?] = [:]
    var effectControls:                 [[SCEffectControl]] = []
    var engine:                         AVAudioEngine?
    var mixer:                          AVAudioMixerNode?
    var sampler:                        AVAudioUnitSampler?
    var nodeIdx:                        Int = 0
    
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
    
    weak var delegate:                  SCGAudioControllerDelegate?
    
    
    // the sequencer
    var sequencer:                      AVAudioSequencer?
    var sequencerTrackLengthSeconds:    Double?
    var sequencerIsPlaying:             Bool = false

    // buffer for the player
    var playerLoopBuffer:               AVAudioPCMBuffer?
    
    // for the node tap
    var mixerOutputFileURL:             URL?
    var isRecording:                    Bool = false
    var isRecordingSelected:            Bool = false
    
    // managing session and configuration changes
    var isSessionInterrupted:           Bool = false
    var isConfigChangePending:          Bool = false
    
    
    
    init() {
        
        self.mixerOutputFileURL = nil
        self.isSessionInterrupted = false
        self.isConfigChangePending = false
        
        effectControls = SCAudioManager.shared.effectControls
        initAVAudioSession()
        loadSamples()
//        getAudioFilesForURL()
        engine = AVAudioEngine.init()
        
        isRecording = false
        isRecordingSelected = false
        
        print("\(String(describing: engine?.description))")
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "ShouldEnginePauseNotification"),
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: {
                                                note in
                                                
                                                /* pausing stops the audio engine and the audio hardware, but does not deallocate the resources allocated by prepare().
                                                 When your app does not need to play audio, you should pause or stop the engine (as applicable), to minimize power consumption.
                                                 */
                                                if !self.isSessionInterrupted && !self.isConfigChangePending {
                                                    if self.playerIsPlaying == true || self.sequencerIsPlaying == true  || self.isRecording == true {
                                                        
                                                        print("Pausing engine.")
                                                        self.engine?.pause()
                                                        self.engine?.reset()
                                                        
                                                        // post notification
                                                        self.delegate?.engineHasBeenPaused()
                                                    }
                                                }
        })
    }
    

    private func createEngine(){
       
        engine = nil
        engine = AVAudioEngine.init()
        print("\(String(describing: engine?.description))")
        
    }
    
    private func startEngine(){
        
        // start the engine
        
        /*  startAndReturnError: calls prepare if it has not already been called since stop.
         
         Starts the audio hardware via the AVAudioInputNode and/or AVAudioOutputNode instances in
         the engine. Audio begins flowing through the engine.
         
         This method will return YES for success.
         
         Reasons for potential failure include:
         
         1. There is problem in the structure of the graph. Input can't be routed to output or to a
         recording tap through converter type nodes.
         2. An AVAudioSession error.
         3. The driver failed to start the hardware. */
        
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
    
    
    
    
    //MARK: AVAudioSequencer Setup
    
    private func createAndSetupSequencer(){
        
        
        /* A collection of MIDI events organized into AVMusicTracks, plus a player to play back the events.
         NOTE: The sequencer must be created after the engine is initialized and an instrument node is attached and connected
         */
        sequencer = AVAudioSequencer(audioEngine: engine!)
        
        //        let options = AVMusicSequenceLoadSMF_PreserveTracks
        
        
        guard let fileURL = URL.init(string: Bundle.main.path(forResource: "bluesyRiff", ofType: "mid")!) else {
            print("error getting url for bluesyRiff")
            return
        }
        
        let options: AVMusicSequenceLoadOptions = []
        do {
            try sequencer?.load(from: fileURL, options: options)
            print("loaded \(fileURL)")
        } catch {
            print("something screwed up \(error)")
            return
        }
        
        
        sequencer?.prepareToPlay()
    }
    
    
    
    //MARK: AVAudioSequencer Methods
    
    func toggleSequencer(){
        
        if (sequencer?.isPlaying)! {
            
            sequencer?.stop()
            NotificationCenter.default.post(Notification.init(name: SCConstants.ShouldEnginePauseNotification))
        }
        
        sequencer?.currentPositionInBeats = TimeInterval(0)
        
        do {
            try sequencer?.start()
        } catch {
            print("cannot start \(error)")
        }
    }
    
    
//    func getSequencerIsPlaying() -> Bool {
//        return self.sequencerIsPlaying
//    }
    
    
    
    func sequencerCurrentPosition() -> Float {
        return fmodf(Float(sequencer!.currentPositionInSeconds), Float(sequencerTrackLengthSeconds!)) / Float(sequencerTrackLengthSeconds!)
        
    }
    
    
    
    private func setSequencerCurrentPosition(sequencerCurrentPosition: Float) {
        sequencer?.currentPositionInSeconds = TimeInterval(Float(sequencerCurrentPosition) * Float(sequencerTrackLengthSeconds!))
        
    }
    
    
    func sequencerPlaybackRate() -> Float {
        return sequencer!.rate
        
    }
    
    
    private func setSequencerPlaybackRate(sequencerPlaybackRate: Float) {
        sequencer?.rate = sequencerPlaybackRate
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
    
    private func setSamplerDirectVolume(sampler: AVAudioUnitSampler, samplerDirectVolume: Float ){
//         get all output connection points from sampler bus 0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: sampler, outputBus: 0))!
        
//         if the destination node represents the main mixer , then this is the direct path r
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
//                get the corresponding mixing destination object and set the mixer input bus volume
                let mixingDestination = sampler.destination(forMixer: connection.node!, bus: connection.bus)
                if mixingDestination != nil {
                    mixingDestination?.volume = samplerDirectVolume
                }
            }
        }
    }
    
    
    func getSamplerDirectVolume(sampler: AVAudioUnitSampler) -> Float {
//                 get all output connection points from sampler bus 0
        samplerDirectVolume = 0.0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: sampler, outputBus: 0))!
        for (_ , connection
            ) in connectionPoints.enumerated() {
                if connection == engine?.mainMixerNode {
                    let mixingDestination = sampler.destination(forMixer: connection.node!, bus: connection.bus)
                    if mixingDestination != nil {
                        samplerDirectVolume = mixingDestination?.volume
                    }
                }
        }
        return samplerDirectVolume!
    }
    
    
    func setSamplerEffectVolume(samplerEffectVolume: Float ) {
        // get all output connection points from sampler bus 0
        guard let distortion = self.distortion else {
            print("Error, distortion node is nil")
            return
        }
        
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: distortion, outputBus: 0))!
        
        // if the destination node represents the distortion effect, then this is the effect path
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                // get the corresponding mixing destination object and set the mixer input bus volume
                guard self.sampler != nil else {
                    print("Error, sampler is nil")
                    return
                }
                let mixingDestination: AVAudioMixingDestination = (self.sampler?.destination(forMixer: (engine?.mainMixerNode)!, bus: 0))!
                mixingDestination.volume = samplerEffectVolume
                break
            }
        }
    }
    
    
    
//    func getSamplerEffectVolume(sampler: AVAudioUnitSampler, distortion: AVAudioUnitDistortion) -> Float {
//        
//        var distortionVolume: Float = 0.0
//        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: distortion, outputBus: 0))!
//        for (_ , connection) in connectionPoints.enumerated() {
//            if connection.node == engine?.mainMixerNode {
//                let mixingDestination: AVAudioMixingDestination = (sampler.destination(forMixer: connection.node!, bus: connection.bus))!
//                distortionVolume = mixingDestination.volume
//            }
//        }
//        return distortionVolume
//    }
    
    
    //MARK: Mixer Methods
    
    private func setOutputVolume(outputVolume: Float){
        
        engine?.mainMixerNode.outputVolume = outputVolume
    }
    
    
//    func getOutputVolume()-> Float {
//        return (engine?.mainMixerNode.outputVolume)!
//    }
   
    
    
    
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
    
    
    /* //MARK: TODO: EQ
     func setupEQ() ->eq {
     var EQNode:AVAudioUnitEQ!
     
     EQNode = AVAudioUnitEQ(numberOfBands: 2)
     engine.attach(EQNode)
     
     var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
     filterParams.filterType = .highPass
     filterParams.frequency = 80.0
     
     filterParams = EQNode.bands[1] as AVAudioUnitEQFilterParameters
     filterParams.filterType = .parametric
     filterParams.frequency = 500.0
     filterParams.bandwidth = 2.0
     filterParams.gain = 4.0
     
     let format = mixer.outputFormat(forBus: 0)
     engine.connect(playerNode, to: EQNode, format: format )
     engine.connect(EQNode, to: engine.mainMixerNode, format: format)
     }
     */
    

    private func setDistortionWetDryMix(distortionWetDryMix: Float){
        distortion?.wetDryMix = distortionWetDryMix * 100.0
        
    }
    
    
//    private func distortionWetDryMix() -> Float {
//        return distortion!.wetDryMix/100.0
//    }
    
    
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
//
//        if activePlayers >= maxPlayers {
//            print("Max players reached.")
//            return
//        }
//
        let mixer = AVAudioMixerNode.init()
        engine?.attach(mixer)
        
        let playerFormat = AVAudioFormat.init(standardFormatWithSampleRate: 44100, channels: 1)
        let mainMixer = (engine?.mainMixerNode)!
        
        let sampler = AVAudioUnitSampler.init()
        engine?.attach(sampler)

        let player = AVAudioPlayerNode.init()
        
        engine?.attach(player)
        
//        if reverb == nil {
        let reverb = AVAudioUnitReverb()
            engine?.attach(reverb)
//        }
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
//        engine?.connect(sampler, to: mainMixer, format: playerFormat)
        
    
        var disconnectNodes = [player, sampler, reverb, delay, pitchShift, timeStretch, distortion]
 
        
//        if let urls: [URL] = Bundle.main.urls(forResourcesWithExtension: "caf", subdirectory: "Documents") {
//            do {
//                try sampler.loadAudioFiles(at: urls)
        //            } catch {
        //                print("No sample\n")
        //            }
        //        }
        
        startEngine()
       
        
//        let dm = SCDataManager.shared
//        guard let sampleBank = dm.user?.sampleBanks[dm.currentSampleBank!] else { return }
//        
//        if let path = sampleBank.samples["\(index)"] {
//            
//            let fileManager = FileManager.default
//            let docsurl = try! fileManager.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//            let myurl = docsurl.appendingPathComponent(path)
//            
//            
//            var urls:[URL] = []
//            urls.append(myurl)
//            do {
//                try sampler.loadAudioFiles(at: urls)
//                
//            } catch {
//                print("No sample\n")
//            }
//        }
        
//        sampler.startNote(50, withVelocity: 64, onChannel: 0)
        
        
        // schedule the appropriate content
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
    
    
    
    
//    func toggleBuffer(recordBuffer: Bool) {
//        
//        isRecordingSelected = recordBuffer
//        
//        switch self.playerIsPlaying {
//        case true:
////            player?.stop()
//            startEngine() // start the engine if it's not already started
//            schedulePlayerContent()
//            player?.play()
//        case false:
//            schedulePlayerContent()
//        }
//    }
//    
    
//    
//    private func schedulePlayerContent(){
//        
//        // schedule the appropriate content
//        let key: String = "\(SCAudioManager.shared.selectedSampleIndex)"
//        guard let sample: AVAudioFile = audioFiles[key]! as? AVAudioFile else {  //createAudioFileForPlayback()!
//            print("No sample at selected sample index!")
//            return
//        }
//        
//        player?.scheduleFile(sample, at: nil, completionHandler: nil)
//    }

    
  
    
    
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
        } catch { //let error {
//            print("Error, couldn't create AVAudioFile, \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    func getAudioFilesForURL(){
        
        let dm = SCDataManager.shared
//        let idx = dm.currentSampleBank
        
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
        // install a tap on the main mixer output bus and write output buffers to file
        
        /*  The method installTapOnBus:bufferSize:format:block: will create a "tap" to record/monitor/observe the output of the node.
         
         @param bus
         the node output bus to which to attach the tap
         @param bufferSize
         the requested size of the incoming buffers. The implementation may choose another size.
         @param format
         If non-nil, attempts to apply this as the format of the specified output bus. This should
         only be done when attaching to an output bus which is not connected to another node; an
         error will result otherwise.
         The tap and connection formats (if non-nil) on the specified bus should be identical.
         Otherwise, the latter operation will override any previously set format.
         Note that for AVAudioOutputNode, tap format must be specified as nil.
         @param tapBlock
         a block to be called with audio buffers
         
         Only one tap may be installed on any bus. Taps may be safely installed and removed while
         the engine is running.
         
         ---------------------------------------------------------------- */
        
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
                // Other nodes/objects can listen to this update accordingly
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
        // Configure the audio session
        let sessionInstance = AVAudioSession.sharedInstance()
        
        // set the session category
        
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
            sequencer?.stop()
            stopRecordingMixerOutput()
            self.delegate?.engineWasInterrupted()
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
        
        self.sequencer = nil  // remove this sequencer since it's linked to the old AVAudioEngine
        
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
        
        // rebuild the world
        createEngine()
//        createAndSetupSequencer()
        
//          // notify the delegate
        self.delegate?.engineConfigurationHasChanged()
    }
  
}
