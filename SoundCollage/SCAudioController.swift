//
//  SCAudioController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/1/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//
/*
 
 Abstract:
 AudioEngine is the main controller class that creates the following objects:
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


struct SCAudioControllerConstants{
    
    static let kRecordingCompletedNotification: Notification.Name = Notification.Name(rawValue: "RecordingCompletedNotification")
    static let kShouldEnginePauseNotification: Notification.Name = Notification.Name(rawValue: "kShouldEnginePauseNotification")
}



protocol SCAudioControllerDelegate: class {
    
    func engineWasInterrupted()
    func engineConfigurationHasChanged()
    func engineHasBeenPaused()
    func mixerOutputFilePlayerHasStopped()
}


class SCAudioController {
//    
//    var recordingIsAvailable:           Bool = false
    var playerIsPlaying:                Bool = false
    var sequencerIsPlaying:             Bool = false
//
//    var sequencerCurrentPosition:       Float?
//    var sequencerPlaybackRate:          Float?
//    
//    var playerVolume:                   Float? // 0.0 - 1.0
//    var playerPan:                      Float? // -1.0 - 1.0
//    
//    var samplerDirectVolume:            Float? // 0.0 - 1.0
    var samplerEffectVolume:            Float? // 0.0 - 1.0
//
//    var distortionWEtDryMix:            Float? // 0.0 - 1.0
//    var distortionPreset:               Int?
//    
//    var reverbWetDryMix:                Float?  // 0.0 - 1.0
//    var reverbPreset:                   Int?
//    
//    var outputVolume:                   Float?  // 0.0 - 1.0
    
    weak var delegate:                  SCAudioControllerDelegate?
    
    
    
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
    let mixerOutputFileURL:             URL?
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
        
        NotificationCenter.default.addObserver(forName: SCAudioControllerConstants.kShouldEnginePauseNotification, object: nil, queue: OperationQueue.main, using: {
            note in
            
            /* pausing stops the audio engine and the audio hardware, but does not deallocate the resources allocated by prepare().
             When your app does not need to play audio, you should pause or stop the engine (as applicable), to minimize power consumption.
             */
            if !self.isSessionInterrupted && !self.isConfigChangePending {
                if self.playerIsPlaying || self.sequencerIsPlaying || self.isRecording {
                
                    print("Pausing engine.")
                    self.engine?.pause()
                    self.engine?.reset()
                    
                    // post notificatino
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
                try drumLoopFile.read(into: playerLoopBuffer!)//:_playerLoopBuffer error:&error];
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
        
        bankURL: URL = URL.fileURLWit//fileURLWithPath:NSBundl bundleForClass:[self class]] pathForResource:@"gs_instruments" ofType:@"dls"]];
        BOOL success = [_sampler loadSoundBankInstrumentAtURL:bankURL program:0 bankMSB:0x79 bankLSB:0 error:&error];
        NSAssert(success, @"couldn't load SoundBank into sampler node, %@", [error localizedDescription]);

    }
    
    
    private func startEngine(){
        
    }
    
    
    //MARK: AVAudioSequencer Setup
    
    private func createAndSetupSequencer(){
        
        
        
    }
    
    
    
    //MARK: AVAudioSequencer Methods
    
    func toggleSequencer(){
        
    }
    
    
    func getSequencerIsPlaying() -> Bool {
       return self.sequencerIsPlaying
    }
    
    func sequencerCurrentPosition() -> Float {
        
    }
    
    private func setSequencerCurrentPosition(sequencerCurrentPosition: Float) {
        
    }
    
    
    func sequencerPlaybackRate() -> Float {
        
    }
    
    
    private func setSequencerPlaybackRate(sequencerPlaybackRate: Float) {
        
    }
    
    
    
    //MARK: AVAudioMixinDestination Methods
    
    private func setSamplerDirectVolume(samplerDirectVolume: Float ){
        
    }
    
    
    func samplerDirectVolume() -> Float {
        
    }
    
    
    private func setSamplerEffectVolume(samplerEffectVolume: Float ) {
        
        
    }
    
    
    
    func samplerEffectVolume() -> Float {
        
    }
    
    
    //MARK: Mixer Methods
    
    private func setOutputVolume(outputVolume: Float){
        
        
    }
    
    
    func outputVolume()-> Float {
        
    }
    
    
    //MARK: Effect Methods
    
    private func setDistortionWetDryMix(distortionWetDryMix: Float){
        
    }
    
    
    private func distortionWetDryMix() -> Float {
        
    }
    
    
    private func setDistortionPreset(distortionPreset: Int) {
        
        
        
    }
    
    
    private func setReverbWetDryMix(reverbWetDryMix: Float) {
        
    }
    
    
    func reverbWetDryMix() -> Float {
        
    }
    
    
    
    private func setReverbPreset(reverbPreset: Float){
        
        
    }
    
    
    //MARK: Player Methods
    
    private func playerIsPLaying() -> Bool {
        
    }
    
    
    private func setPlayerVolume(playerVolume: Float) {
        
    }
    
    
    private func setPlayerPan(playerPan: Float){
        
    }
    
    
    func playerVolume() -> Float {
        
    }
    
    
    func playerPan() -> Float {
        
    }
    
    func togglePlayer(){
        
    }
    
    
    
    func toggleBuffer(recordBuffer: Bool) {
        
    }
    
    
    
    private func schedulePlayerContent(){
        
    }
    
    
    private func createAudioFileForPlayback() -> AVAudioFile {
        
    }
    
    
    
    //MARK: Recording Methods
    
    func startRecordingMixerOutput(){
        
    }
    
    
    func stopRecordingMixerOutput(){
        
    }
    
    
    
    func recordingIsAvailable() -> Bool {
        
    }
    
    
    
    //MARK: AVAudioSession
    
    private func initAVAudioSession(){
        
    }
    
    
    private func handleInterruption(notification: Notification) {
        
    }
    
    
    
    private func handleRouteChange(notification: Notification) {
        
    }
    
    
    private func handleMediaServicesReset(notification: Notification) {
        
    }
    
    
    
    
    
    
    
}
