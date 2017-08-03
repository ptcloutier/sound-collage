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
//    var samplerEffectVolume:            Float? // 0.0 - 1.0
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
        
    }
    
    
    private func makeEngineConnections(){
        
    }
    
    
    private func setNodeDefaults(){
        
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
