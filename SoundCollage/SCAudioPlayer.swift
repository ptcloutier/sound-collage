//
//  AudioPlayer.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/11/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import AVFoundation

class SCAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let shared = SCAudioPlayer()
    
    private override init() {}
    
    var players = [URL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    let session:AVAudioSession = AVAudioSession.sharedInstance()
 
    func playSound (soundFileURL: URL){
        
//        let soundFileNameURL = URL(fileURLWithPath: Bundle.main.path(forResource: soundFileName, ofType: "m4a", inDirectory:"Sounds")!)
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        if let player = players[soundFileURL] { //player for sound has been found
            
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
                
            } else { // player is in use, create a new, duplicate, player and use that instead
                
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: soundFileURL)
                //use 'try!' because we know the URL worked before.
                
                duplicatePlayer.delegate = self
                //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                
                duplicatePlayers.append(duplicatePlayer)
                //add duplicate to array so it doesn't get removed from memory before finishing
                
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.play()
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do{
                let player = try AVAudioPlayer(contentsOf: soundFileURL)
                players[soundFileURL] = player
                player.prepareToPlay()
                player.play()
            } catch {
                print("Could not play sound file!")
            }
        }
    }
    
//    
//    func playSounds(soundFileNames: [String]){
//        
//        for soundFileName in soundFileNames {
//            playSound(soundFileName: soundFileName)
//        }
//    }
//    
//    func playSounds(soundFileNames: String...){
//        for soundFileName in soundFileNames {
//            playSound(soundFileName: soundFileName)
//        }
//    }
    
//    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
//        for (index, soundFileName) in soundFileNames.enumerated() {
//            let delay = withDelay*Double(index)
//            let _ = Timer.scheduledTimerWithTimeInterval(delay, target: self, selector: #selector(AudioRecorder.playSoundNotification(_:)), userInfo: ["fileName":soundFileName], repeats: false)
//        }
//    }
//    
//    func playSoundNotification(notification: NSNotification) {
//        if let soundFileName = notification.userInfo?["fileName"] as? String {
//            playSound(soundFileName: soundFileName)
//        }
//    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at: duplicatePlayers.index(of: player)!)
        //Remove the duplicate player once it is done
    }
    
}
