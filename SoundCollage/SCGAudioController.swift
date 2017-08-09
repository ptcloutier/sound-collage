//
//  SCGAudioController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/6/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
/*
 
 Abstract:
 SCGAudioController is the main controller class that creates the following objects:
 AVAudioEngine               *_engine;
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


struct SCConstants{
    
    static let RecordingCompletedNotification: NSNotification.Name = Notification.Name(rawValue: "RecordingCompletedNotification")
    static let ShouldEnginePauseNotification: NSNotification.Name = Notification.Name(rawValue: "ShouldEnginePauseNotification")
}



protocol SCGAudioControllerDelegate: class {
    
    func engineWasInterrupted()
    func engineConfigurationHasChanged()
    func engineHasBeenPaused()
    func mixerOutputFilePlayerHasStopped()
}


class SCGAudioController {
    
    var usedPlayers:                    Int = 0
    var plays:                          Int = 0
    var finishedNodes:                  [AVAudioNode] = []
    var nodeChain:                      [AnyObject] = []
    var audioFiles:                     [String : AnyObject?] = [:]
    var effectControls:                 [[SCEffectControl]] = []
    var engine:                         AVAudioEngine?
    var mixer:                          AVAudioMixerNode?
    var sampler:                        AVAudioUnitSampler?
    var nodeIdx:                        Int = 0
    var players:                        [SCAudioPlayerNode] = []
    var reverbNodes:                    [AVAudioUnitReverb] = []
    var distortionNodes:                [AVAudioUnitDistortion] = []
    var delayNodes:                     [AVAudioUnitDelay] = []
    var pitchShiftNodes:                [AVAudioUnitTimePitch] = []
    var timeStretchNodes:               [AVAudioUnitVarispeed] = []
    var mixerOutputFile:                AVAudioFile!
    var recordingIsAvailable:           Bool = false
    var playerIsPlaying:                Bool = false
    var playerVolume:                   Float? // 0.0 - 1.0
    var playerPan:                      Float? // -1.0 - 1.0
    //
    var samplerDirectVolume:            Float? // 0.0 - 1.0
    var samplerEffectVolume:            Float? // 0.0 - 1.0
    //
    //    var distortionWetDryMix:            Float? // 0.0 - 1.0
    //    var distortionPreset:               Int?
    //
    //    var reverbWetDryMix:                Float?  // 0.0 - 1.0
    var reverbPreset:                   Int?
    //
    //    var outputVolume:                   Float?  // 0.0 - 1.0
    
    weak var delegate:                  SCGAudioControllerDelegate?
    
    
    
    // private class extensions
    
    // AVAudioEngine and AVAudioNodes
    
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
        getAudioFilesForURL()
        setupAVAudioEngineAndAttachNodes()

        
        print("\(String(describing: engine?.description))")
        
        NotificationCenter.default.addObserver(forName: SCConstants.ShouldEnginePauseNotification,
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
    
    
    //MARK: AVAudioEngine Setup
    private func setupAVAudioEngineAndAttachNodes(){
        
        engine = AVAudioEngine.init()
        
        
        isRecording = false
        isRecordingSelected = false
        
        mixer = AVAudioMixerNode.init()
        engine?.attach(mixer!)

//        sampler = AVAudioUnitSampler.init()
//        engine?.attach(sampler!)

        /*  To support the instantiation of arbitrary AVAudioNode subclasses, instances are created
         externally to the engine, but are not usable until they are attached to the engine via
         the attachNode method. */
        
    }
    
    
    
    private func setNodeDefaults(){
        
  /*
        // settings for effects units
        reverb?.wetDryMix = 40.0
        reverb?.loadFactoryPreset( AVAudioUnitReverbPreset.mediumHall)
        
        distortion?.loadFactoryPreset( AVAudioUnitDistortionPreset.drumsBitBrush)
        distortion?.wetDryMix = 100
        self.samplerEffectVolume = 0
        
        
        /*
        if let urls: [URL] = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: "wavs") {  // TODO: use our urls
            do {
                try sampler?.loadAudioFiles(at: urls)
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            }
        }
        */
        
        /*  ------------ Original Method ---------------
         
         guard let bankURL: URL = URL.init(string: Bundle.main.path(forResource: "gs_instruments", ofType: "dls")!) else {
         print("could not load sound files")
         return
         }
         
         do {
         try self.sampler?.loadSoundBankInstrument(at: bankURL,
         program: 0,
         bankMSB: 0x79,
         bankLSB: 0)
         } catch {
         print("error loading sound bank instrument")
         } */
    
    */
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
    
    /*
    
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
    
    
    func getSequencerIsPlaying() -> Bool {
        return self.sequencerIsPlaying
    }
    
    
    
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
    
    private func setSamplerDirectVolume(sampler: AVAudioUnitSampler, samplerDirectVolume: Float ){
        // get all output connection points from sampler bus 0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: sampler, outputBus: 0))!
        
        // if the destination node represents the main mixer , then this is the direct path r
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                //get the corresponding mixing destination object and set the mixer input bus volume
                let mixingDestination = sampler.destination(forMixer: connection.node!, bus: connection.bus)
                if mixingDestination != nil {
                    mixingDestination?.volume = samplerDirectVolume
                }
            }
        }
    }
    
    
    func getSamplerDirectVolume(sampler: AVAudioUnitSampler) -> Float {
        //        // get all output connection points from sampler bus 0
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
    
    
    private func setSamplerEffectVolume(sampler: AVAudioUnitSampler, distortion: AVAudioUnitDistortion, samplerEffectVolume: Float ) {
        // get all output connection points from sampler bus 0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: distortion, outputBus: 0))!
        
        // if the destination node represents the distortion effect, then this is the effect path
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                // get the corresponding mixing destination object and set the mixer input bus volume
                let mixingDestination: AVAudioMixingDestination = (sampler.destination(forMixer: connection.node!, bus: connection.bus))!
                mixingDestination.volume = samplerEffectVolume
            }
        }
    }
    
    
    
    func getSamplerEffectVolume(sampler: AVAudioUnitSampler, distortion: AVAudioUnitDistortion) -> Float {
        
        var distortionVolume: Float = 0.0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: distortion, outputBus: 0))!
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                let mixingDestination: AVAudioMixingDestination = (sampler.destination(forMixer: connection.node!, bus: connection.bus))!
                distortionVolume = mixingDestination.volume
            }
        }
        return distortionVolume
    }
    
    
    //MARK: Mixer Methods
    
    private func setOutputVolume(outputVolume: Float){
        
        engine?.mainMixerNode.outputVolume = outputVolume
    }
    
    
    func outputVolume()-> Float {
        return (engine?.mainMixerNode.outputVolume)!
    }
    */
    
    
    
    //MARK: Effect Methods
 
    
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
    
 /*
    private func setDistortionWetDryMix(distortionWetDryMix: Float){
        distortion?.wetDryMix = distortionWetDryMix * 100.0
        
    }
    
    
    private func distortionWetDryMix() -> Float {
        return distortion!.wetDryMix/100.0
    }
    
    
    private func setDistortionPreset(distortionPreset: Int) {
        if distortion != nil {
            distortion?.loadFactoryPreset(AVAudioUnitDistortionPreset(rawValue: distortionPreset)!)
        }
    }
    
    
    private func setReverbWetDryMix(reverbWetDryMix: Float) {
        reverb?.wetDryMix = reverbWetDryMix * 100.0
        
    }
    
    
    func reverbWetDryMix() -> Float {
        return reverb!.wetDryMix/100.0
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
    
    
    func togglePlayer(){
        switch self.playerIsPlaying {
        case true:
            player?.stop()
            NotificationCenter.default.post(name: SCConstants.ShouldEnginePauseNotification, object: nil)
        case false:
            startEngine()
            schedulePlayerContent()
            player?.play()
        }
    }
    
    
    
    func toggleBuffer(recordBuffer: Bool) {
        
        isRecordingSelected = recordBuffer
        
        switch self.playerIsPlaying {
        case true:
            player?.stop()
            startEngine() // start the engine if it's not already started
            schedulePlayerContent()
            player?.play()
        case false:
            schedulePlayerContent()
        }
    }
    
    
    
    private func schedulePlayerContent(){
        
        // schedule the appropriate content
        switch isRecordingSelected {
        case true:
            let recording: AVAudioFile = createAudioFileForPlayback()!
            player?.scheduleFile(recording, at: nil, completionHandler: nil)
        case false:
            player?.scheduleBuffer(playerLoopBuffer!, at: nil, options: .loops, completionHandler: nil)
        }
    }
*/
    
  
    
    
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
        
        guard let samples = SCDataManager.shared.user?.currentSampleBank?.samples else { return }
        
        audioFiles = samples
        
        for (key, value) in audioFiles {
//            print("AudioFiles key : \(key), val: \(String(describing: value))")
            
            let path = SCAudioManager.shared.getPathForSampleIndex(sampleIndex: Int(key)!)
            if let audioFile: AVAudioFile = getSample(samplePath: path!) {
                
                
//                print("Audiofile: \(String(describing: audioFile))")
                audioFiles.updateValue(audioFile, forKey: key)
                print("AudioFiles key : \(key), val : \(String(describing: value))")
            }
        }
    }
    
    
    
    
    
    func playSample(sampleURL: URL, senderID: Int) {
        
        
        guard let sampleIdx = SCAudioManager.shared.getIndex(senderID: senderID) else { return }
        //        let effectControls = SCAudioManager.shared.effectControls
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error {
            print("Error setting avaudiosession category, \(error.localizedDescription)")
        }
        let key = "\(sampleIdx)"
        guard let sample: AVAudioFile = audioFiles[key]! as? AVAudioFile else {
            print("No audiofile")
            return
        }

//            playerLoopBuffer = AVAudioPCMBuffer.init(pcmFormat: sample.processingFormat, frameCapacity: AVAudioFrameCount(sample.length))
//            do {
//                try sample.read(into: playerLoopBuffer!)
//            } catch let error {
//                print("Error reading buffer from file\(error.localizedDescription)")
//            }
/*
         
            
 
            // establish a connection between nodes
            // connect the player to the reverb
            // use the buffer format for the connection format as they must match
            engine?.connect(player, to: reverb!, format: playerFormat)

           // connect the reverb effect to mixer input bus 0
           // use the buffer format for the connection format as they must match
            engine?.connect(reverb!, to: (engine?.mainMixerNode)!, fromBus: 0,  toBus: 0, format: playerFormat)
           
//            // connect the distortion effect to mixer input bus 2
           
            engine?.connect(distortion!, to: (engine?.mainMixerNode)!, fromBus: 0, toBus: 2,  format:stereoFormat)
            
         
            // fan out the sampler to mixer input 1 and distortion effect
            
            let destinationNodes = [
                AVAudioConnectionPoint.init(node: (engine?.mainMixerNode)!, bus: 1),
                AVAudioConnectionPoint.init(node: distortion!, bus: 0)
            ]
            engine?.connect(sampler!, to: destinationNodes, fromBus: 0, format: stereoFormat)
*/
            let playerFormat = AVAudioFormat.init(standardFormatWithSampleRate: 44100, channels: 1)//playerLoopBuffer?.format
//            let stereoFormat = AVAudioFormat.init(standardFormatWithSampleRate: 44100, channels: 2)
 
            let player = SCAudioPlayerNode.init()
            let reverb = setupReverb(sampleIndex: sampleIdx)
            let delay = setupDelay(sampleIndex: sampleIdx)
            let distortion = setupDistortion(sampleIndex: sampleIdx)
            let pitchShift = setupPitchShift(sampleIndex: sampleIdx)
            let timeStretch = setupTimeStretch(sampleIndex: sampleIdx)
            engine?.attach(player)
            engine?.attach(reverb)
            engine?.attach(delay)
            engine?.attach(pitchShift)
            engine?.attach(timeStretch)
            engine?.attach(distortion)

            engine?.connect(player, to: pitchShift, format: playerFormat)
            engine?.connect(pitchShift, to: timeStretch, format: playerFormat)
            engine?.connect(timeStretch, to: distortion, format: playerFormat)
            engine?.connect(distortion, to: delay, format: playerFormat)
            engine?.connect(delay, to: reverb, format: playerFormat)
            engine?.connect(reverb, to: mixer!, format: playerFormat)
            engine?.connect(mixer!, to: (engine?.mainMixerNode)!, format: playerFormat)
//            engine?.connect(player, to: reverb, format: playerFormat)
//            engine?.connect(reverb, to: (engine?.mainMixerNode)!, fromBus: 0, toBus: 0, format: playerFormat)
//            engine?.connect(distortion, to: (engine?.mainMixerNode)!, fromBus: 0, toBus: 2, format: stereoFormat)
//            let destinationNodes = [
//            AVAudioConnectionPoint.init(node: (engine?.mainMixerNode)!, bus: 1),
//            AVAudioConnectionPoint.init(node: distortion, bus: 0)
//            ]
//            engine?.connect(sampler!, to: destinationNodes, fromBus: 0, format: stereoFormat)
//
            let nodes = [player, reverb, delay, distortion, timeStretch, pitchShift]
            playIt(player: player, sample: sample, audioNodes: nodes)
//        } catch let error {
//            print("Error, couldn't create AVAudioFile, \(error.localizedDescription)")
//        }
    }
    
    
    
    func playIt(player: SCAudioPlayerNode, sample: AVAudioFile, audioNodes: [AVAudioNode]){
        
        var nodes = audioNodes
        player.isActive = true
        plays = plays+1
        usedPlayers = usedPlayers+1
        
        print("plays : \(plays)")
        var durationInt = Int(round(Double(sample.length)/44100))
        if durationInt == 0 {
            durationInt = 1
        }
        let reverbParameter = SCAudioManager.shared.effectControls[0][0].parameter[SCAudioManager.shared.selectedSampleIndex]
        let reverbTime = round(Float(reverbParameter * 10.0))
        durationInt += Int(reverbTime)
        let delayParams = SCAudioManager.shared.effectControls[1][2].parameter[SCAudioManager.shared.selectedSampleIndex]
        let delayTime = round(Float(delayParams * 10.0))
        durationInt += Int(delayTime)
        let duration = DispatchTimeInterval.seconds(durationInt)
        
        player.scheduleFile(sample, at: nil, completionHandler:{
            
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            //  calculate audio tail based on reverb and delay parameters
            
                let delayQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
                delayQueue.asyncAfter(deadline: .now()+duration){
                    
                    strongSelf.usedPlayers = strongSelf.usedPlayers-1
                    for node in nodes {
                        strongSelf.engine?.disconnectNodeInput(node)
                        strongSelf.engine?.detach(node)
                        
                    }
                    nodes.removeAll()
                    print("used players: \(strongSelf.usedPlayers)")
                }
            })
        engine?.prepare()
        do {
            try engine?.start()
        } catch _ {
            print("Play session Error")
        }
        player.play()
        
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
                mixerOutputFileURL = URL.init(string: NSTemporaryDirectory()+"sound_collage_"+"\(id)"+".aac")
            }
            
            
            let mainMixer = engine?.mainMixerNode

            
            let settings  = [AVSampleRateKey: 44100,
                             AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                             AVNumberOfChannelsKey: 2,
                             AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
            
            let format: AVAudioFormat = AVAudioFormat.init(settings: settings)
            
            do {
                mixerOutputFile = try AVAudioFile.init(forWriting: mixerOutputFileURL!, settings: format.settings)
            } catch let error {
                print("mixerOutputFile is nil, \(error.localizedDescription)")
            }
            
            
            mainMixer?.installTap(onBus: 0, bufferSize: 4096, format: mainMixer?.outputFormat(forBus: 0), block:  {
                (buffer : AVAudioPCMBuffer!, when : AVAudioTime!) in
                print("Got buffer of length: \(buffer.frameLength) at time: \(when)")
                
//                let numChans = Int(pcmBuffer.format.channelCount)
//                let flength = Int(pcmBuffer.frameLength)
//                
//                if let chans = pcmBuffer.floatChannelData?.pointee {
//                    for a in 0..<numChans {
//                        let samples = chans.advanced(by: a)
//                        
//                        for b in 0..<flength {
//                            let sampleP = samples.advanced(by: b)
//                            let sample = sampleP.pointee
//                            print("sample: \(sample)")
//                        }
//                    }
//                }
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
        
        guard let path = self.mixerOutputFileURL?.absoluteString else { return }
        print("Recorded output to \(path)")
        
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
    
    
    
    func getRecordingIsAvailable() -> Bool {
        
        var result: Bool
        
        if mixerOutputFile != nil {
            result = true
        } else {
            result = false
        }
        return result
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
    
    
    @objc func handleInterruption(notification: NSNotification) {// TODO: not handling this
     /*
        let interruptionDict = notification.userInfo
        let interruptionType = interruptionDict?[AVAudioSessionInterruptionTypeKey] as! AVAudioSessionInterruptionType
        
        switch interruptionType {
            
        case .began:
            print("Session interrupted > --- Begin Interruption ---\n")
            isSessionInterrupted = true
//            player?.stop()
            sequencer?.stop()
            stopRecordingMixerOutput()
            self.delegate?.engineWasInterrupted()
        case .ended:
            print("Session interrupted > --- End Interruption ---\n")
            // make sure to activate the session
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                isSessionInterrupted = false
                if isConfigChangePending == true {
                    // there is a pending config changed notification
                    print("Responding to earlier engine config change notification. Re-wiring connections")
//                    makeEngineConnections()
                    isConfigChangePending = false
                }
            } catch let error {
                print("AVAudioSession set active failed with error, \(error.localizedDescription)")
            }
        }*/
    }
    
    
    
    @objc func handleRouteChange(notification: NSNotification) {
        
       /*
        guard let userInfo = notification.userInfo else {
            print("No notification userInfo.")
            return
        }
        let routeChangedReason = userInfo[AVAudioSessionRouteChangeReasonKey] as! Int
        if routeChangedReason == 1 || routeChangedReason == 2 {
            SCAudioManager.shared.observeAudioIO()
        }
        print("reason : \(routeChangedReason)")
        
//        let reasonDict = notification.userInfo
//        let reason = reasonDict?[AVAudioSessionRouteChangeReasonKey] as? Int
//        print("Route change:")
//        switch reason {
//            
//        case AVAudioSessionRouteChangeNewDeviceAvailable:
//            print("     NewDeviceAvailable")
//            break
//        case .oldDeviceUnavailable:
//            print("     OldDeviceUnavailable")
//            break
//        case .categoryChange:
//            print("     CategoryChange")
//            print("     New Category: \(AVAudioSession.sharedInstance().category)")
//            break
//        case .override:
//            print("     Override")
//            break
//        case .wakeFromSleep:
//            print("     WakeFromSleep")
//            break
//        case .noSuitableRouteForCategory:
//            print("     NoSuitableRouteForCategory")
//            break
//        default:
//            print("     ReasonUnknown")
//        }*/
    }
    
    
    
    @objc func handleMediaServicesReset(notification: NSNotification) {
    /*    // if we've received this notification, the media server has been reset
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
//        initAndCreateNodes()
//        createEngineAndAttachNodes()
//        makeEngineConnections()
//        createAndSetupSequencer() // recreate the sequencer with the new AVAudioEngine
//        setNodeDefaults()
//        
        // notify the delegate
        self.delegate?.engineConfigurationHasChanged() */
    }
  
}
