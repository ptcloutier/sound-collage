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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        animationBackground = SKSpriteNode(color: UIColor.clear, size: size)
        animationBackground.anchorPoint = CGPoint(x: 0, y: 1.0)
        animationBackground.position = CGPoint(x: 0, y: 0)
        self.addChild(animationBackground)
    }
    
    
    
    override func update(_ currentTime: CFTimeInterval) {
        degradeShape()
    }
    
    
    
    
    func addShape(color: UIColor, atLocation: CGPoint) {
        let shape = SKShapeNode(rectOf: CGSize.init(width: 100.0, height: 100.0), cornerRadius: 10.0)
        shape.fillColor = color
        shape.blendMode = .add 
        shape.strokeColor = shape.fillColor
        shape.alpha = 0.9
        shape.glowWidth = 0.3
        animationBackground.addChild(shape)
        let convertedPosition = convertPosition(node: shape, position: atLocation)
        shape.position = convertedPosition!
    }
    
    
    
    func convertPosition(node: SKShapeNode, position: CGPoint) -> CGPoint? {
        let newX = position.x
        let newY = (-1)*position.y
        let newPoint = CGPoint(x: newX, y: newY)
        print("shape position - \(newX), \(newY)")
        return newPoint
    }
    
    
    
    func degradeShape() {
        for child in animationBackground.children {
            let shape = child as! SKShapeNode
            shape.glowWidth += 0.3
            shape.alpha -= 0.03
            if shape.alpha <= 0.0 {
                    shape.removeFromParent()
                    print("removed shape")
            }
        }
    }
    
    
    
    func moveShape(){
        for child in animationBackground.children {
            let xOffset: CGFloat = CGFloat(arc4random_uniform(30)) - 10.0
            let yOffset: CGFloat = 40.0
            let newLocation = CGPoint(x: child.position.x + xOffset/2, y: child.position.y + yOffset)
            let moveAction = SKAction.move(to: newLocation, duration: 0.2)
            child.run(moveAction)
        }
    }
}
