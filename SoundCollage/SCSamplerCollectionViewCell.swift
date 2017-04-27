//
//  SamplerCollectionViewCell.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation



class SCSamplerCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate {
    
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int = 0
    var recordingTimer: Timer? = nil
    var flashingOn = false
    var recordingIsEnabled = false

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createColorSets()
        createGradientLayer()
        changeColor()
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: UI Gradient Colors
    
    private func createGradientLayer() { //TODO: make an extension for these gradient color methods
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colorSets[currentColorSet]
        gradientLayer.locations = [0.0, 0.35]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.contentView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    
    private func createColorSets() {
        
        colorSets.append([UIColor.red.cgColor, UIColor.magenta.cgColor, UIColor.orange.cgColor, UIColor.lightGray.cgColor,UIColor.blue.cgColor, UIColor.yellow.cgColor])
        colorSets.append([UIColor.darkGray.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor,UIColor.cyan.cgColor, UIColor.blue.cgColor, UIColor.purple.cgColor])
        
        currentColorSet = 0
    }
    
    
    
    func changeColor() {
        
        if currentColorSet < colorSets.count - 1 {
            currentColorSet += 1
        } else {
            currentColorSet = 0
        }
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 0.7
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    
    
    
    func tryTimer() {
        switch recordingIsEnabled {
        case true:
            print("record enabled")
            startTimer()
        case false:
            if recordingTimer != nil {
                recordingTimer?.invalidate()
            }
        }
    }
    
    
    
    func startTimer(){
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.5,
                                              repeats: true) {
                                                
                                                //"[weak self]" creates a "capture group" for timer
                                                [weak self] timer in
                                                
                                                //Add a guard statement to bail out of the timer code
                                                //if the object has been freed.
                                                guard self != nil else {
                                                    return
                                                }
                                                //Put the code that be called by the timer here.
                                                self?.animateCell()
                                                //                                        strongSelf.someOtherProperty = someValue
        }
    }
    
    
    func animateCell() {
        
        changeColor()
        UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 0,
                       initialSpringVelocity: 50,options: [],
                       animations:{
        self.changeColor()
        })

    }
}
