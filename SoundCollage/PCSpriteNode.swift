//
//  PCShapeNode.swift
//  SoundCollage
//
//  Created by Perrin Cloutier on 1/30/18.
//  Copyright © 2018 ptcloutier. All rights reserved.
//


import UIKit
import SpriteKit

class PCSpriteNode: SKSpriteNode {
    
    var timer = Timer()

    
    
    
    func startDegradeShapeTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(PCSpriteNode.degradeShape), userInfo: nil, repeats: true)
    }
    
    @objc func degradeShape(){
//        glowWidth += 0.3
        alpha -= 0.03
        if alpha <= 0.0 {
            removeFromParent()
            timer.invalidate()
            print("bye bye")
        }
    }
}

