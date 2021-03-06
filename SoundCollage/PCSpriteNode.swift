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
    weak var spriteSceneDelegate: PCSpriteSceneDelegate?

    
    
    func setupSpriteSceneDelegate(delegate: PCSpriteSceneDelegate){
        
        spriteSceneDelegate = delegate
    }
    
    
    func startDegradeShapeTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(PCSpriteNode.degradeShape), userInfo: nil, repeats: true)
    }
    
    
    @objc func degradeShape(){
        alpha -= 0.05
        if alpha <= 0.0 {
            self.spriteSceneDelegate?.printChildrenCount(sender: self)
            removeFromParent()
            timer.invalidate()
        }
    }
}

