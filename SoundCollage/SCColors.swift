//
//  SCColors.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/22/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//


import Foundation
import QuartzCore

class SCColors {
    
    var colors = [[CGColor]]()
    var currentColors: Int = 0
    var gradientLayer = CAGradientLayer()
    
    init(colors: [[CGColor]]) {
        self.colors = colors
    }
    
    //MARK: Gradient color
    func configureGradientLayer(in view: UIView, from startPoint: CGPoint, to endPoint: CGPoint) { 
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
//        view.layer.addSublayer(gradientLayer)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    func morphColors() {
        if currentColors < colors.count - 1 {
            currentColors+=1
        } else {
            currentColors = 0
        }
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 0.1
        colorChangeAnimation.toValue = colors[currentColors]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    
}
