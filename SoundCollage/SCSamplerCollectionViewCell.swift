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
    var isEnabled = false
    var timer: Timer? = nil
//    var audioFile: SCAudioFile?
    
    
    
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
        colorChangeAnimation.duration = 0.4
        colorChangeAnimation.toValue = colorSets[currentColorSet]
        colorChangeAnimation.fillMode = kCAFillModeForwards
        colorChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }
    

    func animateCellForPlayback() {
        
        changeColor() // call change color twice to return to original color
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0,
                       initialSpringVelocity: 50,options: [.repeat],
                       animations:{
        self.changeColor()
        })
    }
    
    
    
    func startCellFlashing() {
        if timer != nil {
            timer?.invalidate()
        }
        startTimer()
    }
    
    
    func stopCellsFlashing() {
        if timer != nil {
            timer?.invalidate()
        }
    }
    
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
            [weak self] timer in  // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.animateCellForPlayback()
        }
    }
    
    func playbackSample() {
        SCAudioManager.shared.playback() 
    }
    
    func recordNewSample() {
        SCAudioManager.shared.recordNew()
 
    }
 
}
