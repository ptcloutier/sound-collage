//
//  AnimationScene.swift
//  AnimationIsand
//
//  Created by Perrin Cloutier on 11/28/17.
//  Copyright © 2017 Perrin Cloutier. All rights reserved.
//

import Foundation
import SpriteKit

class AnimationScene: SKScene {
    
    var colors = [UIColor]()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1.0)
    }
    
 
    
    
    func addShape(color: UIColor, atLocation: CGPoint, rectWidth: CGFloat ) {
     
        
        let sprite = PCSpriteNode(color: color, size: CGSize.init(width: rectWidth+10.0, height: rectWidth+10.0))
        sprite.setupSpriteSceneDelegate(delegate: self)
        sprite.blendMode = .add
        addChild(sprite)
        let convertedPosition = convertPosition(node: sprite, position: atLocation)
        sprite.position = convertedPosition!
        sprite.startDegradeShapeTimer()
    }
    
  
    
    func convertPosition(node: PCSpriteNode, position: CGPoint) -> CGPoint? {
        let newX = position.x
        let newY = (-1)*position.y
        let newPoint = CGPoint(x: newX, y: newY)
        print("shape position - \(newX), \(newY)")
        return newPoint
    }
    
    
    func moveShape(){
        for child in children {
            let xOffset: CGFloat = CGFloat(arc4random_uniform(30)) - 10.0
            let yOffset: CGFloat = 40.0
            let newLocation = CGPoint(x: child.position.x + xOffset/2, y: child.position.y + yOffset)
            let moveAction = SKAction.move(to: newLocation, duration: 0.2)
            child.run(moveAction)
        }
    }
   
}






extension AnimationScene: PCSpriteSceneDelegate {
    
    func printChildrenCount(sender: PCSpriteNode){
        print("sprite count \(children.count)")
    }
}

