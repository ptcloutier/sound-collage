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
    
    var mixerOutputFile:                AVAudioFile!
    var recordingIsAvailable:           Bool = false
    var playerIsPlaying:                Bool = false
    var sequencerIsPlaying:             Bool = false
    //
    //    var sequencerCurrentPosition:       Float?
    //    var sequencerPlaybackRate:          Float?
    //
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
    var engine:                         AVAudioEngine?
    var sampler:                        AVAudioUnitSampler?
    var distortion:                     AVAudioUnitDistortion?
    var reverb:                         AVAudioUnitReverb?
    var player:                         AVAudioPlayerNode?
    
    // the sequencer
    var sequencer:                      AVAudioSequencer?
    var sequencerTrackLengthSeconds:    Double?
    
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
        
        initAVAudioSession()
        initAndCreateNodes()
        createEngineAndAttachNodes()
        makeEngineConnections()
        createAndSetupSequencer()
        setNodeDefaults()
        
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
    private func initAndCreateNodes(){
        
        engine = nil
        sampler = nil
        distortion = nil
        reverb = nil
        player = nil
        
        // create the various nodes
        
        /*  AVAudioPlayerNode supports scheduling the playback of AVAudioBuffer instances,
         or segments of audio files opened via AVAudioFile. Buffers and segments may be
         scheduled at specific points in time, or to play immediately following preceding segments. */
        
        player = AVAudioPlayerNode.init()
        
        /* The AVAudioUnitSampler class encapsulates Apple's Sampler Audio Unit.
         The sampler audio unit can be configured by loading different types of instruments such as an “.aupreset” file,
         a DLS or SF2 sound bank, an EXS24 instrument, a single audio file or with an array of audio files.
         The output is a single stereo bus. */
        
        sampler = AVAudioUnitSampler.init()
        
        /* An AVAudioUnitEffect that implements a multi-stage distortion effect */
        
        distortion = AVAudioUnitDistortion.init()
        
        /*  A reverb simulates the acoustic characteristics of a particular environment.
         Use the different presets to simulate a particular space and blend it in with
         the original signal using the wetDryMix parameter. */
        
        reverb = AVAudioUnitReverb.init()
        
        // load drumloop into a buffer for the playernode
        do {
            let drumLoopURL = URL.init(fileURLWithPath: Bundle.main.path(forResource: "drumLoop", ofType: "caf")!)
            let drumLoopFile = try AVAudioFile.init(forReading: drumLoopURL)
            playerLoopBuffer = AVAudioPCMBuffer.init(pcmFormat: drumLoopFile.processingFormat, frameCapacity: AVAudioFrameCount(drumLoopFile.length))
            do {
                try drumLoopFile.read(into: playerLoopBuffer!)
            } catch let error {
                print("Error reading buffer from file\(error.localizedDescription)")
            }
        } catch let error {
            print("Error reading audio file \(error.localizedDescription)")
        }
        
        isRecording = false
        isRecordingSelected = false
        
    }
    
    private func createEngineAndAttachNodes(){
        
        /*  An AVAudioEngine contains a group of connected AVAudioNodes ("nodes"), each of which performs
         an audio signal generation, processing, or input/output task.
         
         Nodes are created separately and attached to the engine.
         
         The engine supports dynamic connection, disconnection and removal of nodes while running,
         with only minor limitations:
         - all dynamic reconnections must occur upstream of a mixer
         - while removals of effects will normally result in the automatic connection of the adjacent
         nodes, removal of a node which has differing input vs. output channel counts, or which
         is a mixer, is likely to result in a broken graph. */
        
        engine = AVAudioEngine.init()
        
        /*  To support the instantiation of arbitrary AVAudioNode subclasses, instances are created
         externally to the engine, but are not usable until they are attached to the engine via
         the attachNode method. */
        
        engine?.attach(sampler!)
        engine?.attach(distortion!)
        engine?.attach(reverb!)
        engine?.attach(player!)
        
    }
    
    
    private func makeEngineConnections(){
        
        /*  The engine will construct a singleton main mixer and connect it to the outputNode on demand,
         when this property is first accessed. You can then connect additional nodes to the mixer.
         
         By default, the mixer's output format (sample rate and channel count) will track the format
         of the output node. You may however make the connection explicitly with a different format. */
        
        // get the engine's optional singleton main mixer node
        let mainMixer = engine?.mainMixerNode
        
        /*  Nodes have input and output buses (AVAudioNodeBus). Use connect:to:fromBus:toBus:format: to
         establish connections betweeen nodes. Connections are always one-to-one, never one-to-many or
         many-to-one.
         
         Note that any pre-existing connection(s) involving the source's output bus or the
         destination's input bus will be broken.
         
         @method connect:to:fromBus:toBus:format:
         @param node1 the source node
         @param node2 the destination node
         @param bus1 the output bus on the source node
         @param bus2 the input bus on the destination node
         @param format if non-null, the format of the source node's output bus is set to this
         format. In all cases, the format of the destination node's input bus is set to
         match that of the source node's output bus. */
        
        let stereoFormat = AVAudioFormat.init(standardFormatWithSampleRate: 44100, channels: 2)
        let playerFormat = playerLoopBuffer?.format
        
        // establish a connection between nodes
        
        // connect the player to the reverb
        // use the buffer format for the connection format as they must match
        engine?.connect(player!, to: reverb!, format: playerFormat)
        
        // connect the reverb effect to mixer input bus 0
        // use the buffer format for the connection format as they must match
        engine?.connect(reverb!, to: mainMixer!, fromBus: 0,  toBus: 0, format: playerFormat)
        
        // connect the distortion effect to mixer input bus 2
        
        engine?.connect(distortion!, to: mainMixer!, fromBus: 0, toBus: 2,  format:stereoFormat)
        
        // fan out the sampler to mixer input 1 and distortion effect
        let destinationNodes: [AVAudioConnectionPoint] = [ AVAudioConnectionPoint.init(node: (engine?.mainMixerNode)!, bus: 1), AVAudioConnectionPoint.init(node: distortion!, bus: 0)]//NSArray<AVAudioConnectionPoint *>
        
        
        
        engine?.connect( sampler!, to: destinationNodes, fromBus: 0, format: stereoFormat)
    }
    
    
    
    
    private func setNodeDefaults(){
        
        
        // settings for effects units
        reverb?.wetDryMix = 40.0
        reverb?.loadFactoryPreset( AVAudioUnitReverbPreset.mediumHall)
        
        distortion?.loadFactoryPreset( AVAudioUnitDistortionPreset.drumsBitBrush)
        distortion?.wetDryMix = 100
        self.samplerEffectVolume = 0
        
        
        
        if let urls: [URL] = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: "wavs") {  // TODO: use our urls
            do {
                try sampler?.loadAudioFiles(at: urls)
            } catch let error as NSError {
                print("\(error.localizedDescription)")
            }
        }
        
        
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
    
    private func setSamplerDirectVolume(samplerDirectVolume: Float ){
        // get all output connection points from sampler bus 0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: sampler!, outputBus: 0))!
        
        // if the destination node represents the main mixer , then this is the direct path r
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                //get the corresponding mixing destination object and set the mixer input bus volume
                let mixingDestination = sampler?.destination(forMixer: connection.node!, bus: connection.bus)
                if mixingDestination != nil {
                    mixingDestination?.volume = samplerDirectVolume
                }
            }
        }
    }
    
    
    func getSamplerDirectVolume() -> Float {
        //        // get all output connection points from sampler bus 0
        samplerDirectVolume = 0.0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: sampler!, outputBus: 0))!
        for (_ , connection
            ) in connectionPoints.enumerated() {
                if connection == engine?.mainMixerNode {
                    let mixingDestination = sampler?.destination(forMixer: connection.node!, bus: connection.bus)
                    if mixingDestination != nil {
                        samplerDirectVolume = mixingDestination?.volume
                    }
                }
        }
        return samplerDirectVolume!
    }
    
    
    private func setSamplerEffectVolume(samplerEffectVolume: Float ) {
        // get all output connection points from sampler bus 0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: distortion!, outputBus: 0))!
        
        // if the destination node represents the distortion effect, then this is the effect path
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                // get the corresponding mixing destination object and set the mixer input bus volume
                let mixingDestination: AVAudioMixingDestination = (sampler?.destination(forMixer: connection.node!, bus: connection.bus))!
                mixingDestination.volume = samplerEffectVolume
            }
        }
    }
    
    
    
    func getSamplerEffectVolume() -> Float {
        
        var distortionVolume: Float = 0.0
        let connectionPoints: [AVAudioConnectionPoint] = (engine?.outputConnectionPoints(for: distortion!, outputBus: 0))!
        for (_ , connection) in connectionPoints.enumerated() {
            if connection.node == engine?.mainMixerNode {
                let mixingDestination: AVAudioMixingDestination = (sampler?.destination(forMixer: connection.node!, bus: connection.bus))!
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
    
    
    //MARK: Effect Methods
    
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
        
        if mixerOutputFileURL == nil {
            mixerOutputFileURL = URL.init(string: NSTemporaryDirectory()+"mixerOutput.caf")
        }
        
        let mainMixer = engine?.mainMixerNode
        
        do {
            mixerOutputFile = try AVAudioFile.init(forWriting: mixerOutputFileURL!, settings: (mainMixer?.outputFormat(forBus: 0).settings)!)
        } catch let error {
            print("mixerOutputFile is nil, \(error.localizedDescription)")
        }
        
        
        mainMixer?.installTap(onBus: 0, bufferSize: 4096, format: mainMixer?.outputFormat(forBus: 0), block:  {
            (buffer : AVAudioPCMBuffer!, when : AVAudioTime!) in
            //print("Got buffer of length: \(buffer.frameLength) at time: \(when)")
            
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
    }
    
    
    func stopRecordingMixerOutput(){
        
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
    
    private func initAVAudioSession(){
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
        
        //
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleInterruption(_:)), name: AVAudioSessionInterruptionNotification, object: theSession)
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: NSNotification.Name.AVAu
        // dioSessionInterruptionNotification, object: sessionInstance)
        
        // we don't do anything special in the route change notification
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: NSNotification.Name.AVAudioSessionRouteChange, object: sessionInstance)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(handleMediaServicesReset), name: NSNotification.Name.AVAudioAudioSessionMediaServicesReset, object: sessionInstance)
        
        // activate the audio session
        do {
            try sessionInstance.setActive(true)
        } catch let error {
            print("Error setting session active!, \(error.localizedDescription)")
        }
    }
    
    
    @objc func handleInterruption(notification: NSNotification) {
        
        let interruptionDict = notification.userInfo
        let interruptionType = interruptionDict?[AVAudioSessionInterruptionTypeKey] as! AVAudioSessionInterruptionType
        
        switch interruptionType {
            
        case .began:
            print("Session interrupted > --- Begin Interruption ---\n")
            isSessionInterrupted = true
            player?.stop()
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
                    makeEngineConnections()
                    isConfigChangePending = false
                }
            } catch let error {
                print("AVAudioSession set active failed with error, \(error.localizedDescription)")
            }
        }
    }
    
    
    
    @objc func handleRouteChange(notification: NSNotification) {
        
        let reasonDict = notification.userInfo
        let reason = reasonDict?[AVAudioSessionRouteChangeReasonKey] as! AVAudioSessionRouteChangeReason
        
        print("Route change:")
        switch reason {
            
        case .newDeviceAvailable:
            print("     NewDeviceAvailable")
            break
        case .oldDeviceUnavailable:
            print("     OldDeviceUnavailable")
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
        initAndCreateNodes()
        createEngineAndAttachNodes()
        makeEngineConnections()
        createAndSetupSequencer() // recreate the sequencer with the new AVAudioEngine
        setNodeDefaults()
        
        // notify the delegate
        self.delegate?.engineConfigurationHasChanged()
    }
}
