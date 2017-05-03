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
    var flashTimer: Timer? = nil
    var touchTimer: Timer? = nil
    var isTouchDelayed: Bool = false
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createColorSets()
        createGradientLayer()
        changeColor()
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func touchDelay(){
        
        self.isUserInteractionEnabled = false
        isTouchDelayed = true
        print("cell interaction delayed.")
        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.enableTouch()
        }
    }
    
    
    
    func enableTouch(){
        self.isUserInteractionEnabled = true
        isTouchDelayed = false 
        print("cell interaction enabled.")
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
        self.contentView.alpha = 0
        
    }
    
    
    
    private func createColorSets() {
        
        colorSets.append([UIColor.red.cgColor, UIColor.magenta.cgColor, UIColor.orange.cgColor, UIColor.lightGray.cgColor,UIColor.blue.cgColor, UIColor.yellow.cgColor])
        colorSets.append([UIColor.lightGray.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor,UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.lightGray.cgColor])
        
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
        self.contentView.alpha = 1.0
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
        startTimer()
    }
    
    
    func stopCellsFlashing() {
        self.contentView.alpha = 0.5
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
    }
    
    func highlightRecordingCell(){
        changeColor()
    }
    
    
    func startTimer() {
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
            [weak self] flashTimer in  // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.animateCellForPlayback()
        }
    }
    
    func playbackSample() {
        SCAudioManager.shared.playback()
        touchDelay()
    }
    
    func recordNewSample() {
        SCAudioManager.shared.recordNew()
        touchDelay()
    }
    
    override var isSelected: Bool {
        didSet {
           
//            self.layer.borderWidth = 0.9
//            self.layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.lightGray
//                .cgColor
            
        }
    }

 
}
