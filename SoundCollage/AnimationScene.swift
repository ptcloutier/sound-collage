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
    
    var animationBackground: SKSpriteNode!
    var colors = [UIColor]()
    var bubbleShouldGrow: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1.0)
        colors.append(UIColor.red)
        colors.append(UIColor.green)
        colors.append(UIColor.blue)
        colors.append(UIColor.yellow)
        colors.append(UIColor.purple)
        colors.append(UIColor.orange)
        let vintColors = SCColor.getVintageColors()
        let psyColors = SCColor.getPsychedelicIceCreamShopColors()
        for x in vintColors {
            colors.append(x)
        }
        for x in psyColors {
            colors.append(x)
        }
        animationBackground = SKSpriteNode(color: UIColor.clear, size: size)
        animationBackground.anchorPoint = CGPoint(x: 0, y: 1.0)
        animationBackground.position = CGPoint(x: 0, y: 0)
        self.addChild(animationBackground)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        addBubble()
        floatBubbles()
        removeExcessBubbles()
    }
    
    func addBubble() {
//        let bubble = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10, height: 10))
        let bubble = SKShapeNode(circleOfRadius: CGFloat(arc4random_uniform(140)))
    
        bubble.fillColor = colors[Int(arc4random_uniform(UInt32(colors.count-1)))]
        bubble.blendMode = .add
        bubble.strokeColor = bubble.fillColor
        bubble.alpha = 0.9
        bubble.glowWidth = bubble.frame.size.width/2
        animationBackground.addChild(bubble)
//         let startingPoint = CGPoint(x: CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.size.width))), y: (-1)*size.height)
        let startingPoint = CGPoint(x: CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.size.width))), y: (-1)*(CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.size.height)))))
        
        
 
        bubble.position = startingPoint
    }
    
    func floatBubbles() {
        for child in animationBackground.children {
            
            let bubble = child as! SKShapeNode
            
//            switch bubbleShouldGrow {
//            case true:
//                grow(bubble: bubble)
//            case false:
//                shrink(bubble: bubble)
//            }
            bubble.glowWidth += 0.1
            bubble.alpha -= 0.05// 0.5 is awesome
            
            let xOffset: CGFloat = CGFloat(arc4random_uniform(30)) - 10.0
            let yOffset: CGFloat = 40.0
            let newLocation = CGPoint(x: child.position.x + xOffset/2, y: child.position.y + yOffset)
            let moveAction = SKAction.move(to: newLocation, duration: 0.2)
            child.run(moveAction)
        }
    }
    
    
    
    func removeExcessBubbles() {
        
        for child in animationBackground.children {
            if child.position.y > 0 {
                child.removeFromParent()
            }
        }
    }
}
