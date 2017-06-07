//
//  SCAudioEngine.swift
//  SoundCollage
//
//  Created by perrin cloutier on 6/2/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation

class SCAudioEngine: AVAudioEngine {
    
    var samplePadID: Int?
    var isFinished: Bool = false
    var plays: Int = 0
    let maxPlays = 30
    var doCreateNewEngine: Bool = false
    
    override init(){
        super.init()
    }
    
    func detachNode(audioPlayerNode: AVAudioPlayerNode){
        
        
        self.disconnectNodeInput(audioPlayerNode)
        plays-=1
        print("Detached node, plays: \(plays)")
        
        resetEngine()
        
        if plays <= 0 || plays >= maxPlays{
            doCreateNewEngine = true
            resetEngine()
        }
    }
    
    
    func resetEngine(){
        let resetQueue = DispatchQueue(label: "com.soundcollage.delayqueue", qos: .userInitiated)
        resetQueue.asyncAfter(deadline: .now() + 5.0) {
            
            self.stop()
            self.reset()
            self.doCreateNewEngine = false
            print("Engine stopped and reset.")
        }
    }
    
    
    
  

 

}
