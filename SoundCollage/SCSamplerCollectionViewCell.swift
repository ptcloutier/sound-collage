//
//  SamplerCollectionViewCell.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation



class SCSamplerCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate, CAAnimationDelegate {
    
    var colorSets = [[UIColor]]()
    var currentColorSet: Int = 0
    var isEnabled = false
    var flashTimer: Timer? = nil
    var touchTimer: Timer? = nil
    var isTouchDelayed: Bool = false
    var fromColors: [CGColor] = []
    var toColors: [CGColor] = []
    var animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
    var gradient = CAGradientLayer()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createColorSets()
        setupGradientLayer()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Gradient colors/animations
    
    
    
    private func createColorSets() {
        
        colorSets.append([UIColor.clear, UIColor.clear, UIColor.clear])
        colorSets.append([UIColor.red, UIColor.magenta, UIColor.orange])
        fromColors = colorSets[currentColorSet].map {$0.cgColor}
        currentColorSet = 0
    }
    
    
    
    private func setupGradientLayer() {
        
        self.gradient.colors = toColors
        self.gradient.frame = self.bounds
        self.gradient.colors = self.colorSets[currentColorSet].map { $0.cgColor }
        self.layer.insertSublayer(self.gradient, at: 0)
        
        animateLayer()
    }
    
    func animateLayer(){
        
        fromColors = self.gradient.colors as! [CGColor]
        toColors = self.colorSets[currentColorSet+1].map {$0.cgColor}
        
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 0.3
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFilterLinear
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        
        self.gradient.add(animation, forKey:"animateGradient")
    }
    
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        self.toColors = self.fromColors;
        self.fromColors = self.gradient.colors as! [CGColor]
    }
    
    
    
    //MARK: UI record enabled/cell flashing
    
    func startCellFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
        startTimer()
    }
    
    
    
    func startTimer() {
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
            [weak self] flashTimer in  // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.animateLayer()
        }
    }

    
    
    func stopCellsFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
    }

    
    
    //MARK: Playback 
    
    
    func playbackSample() {
        SCAudioManager.shared.playback()
        touchDelay()
    }
    
    func recordNewSample() {
        SCAudioManager.shared.recordNew()
        touchDelay()
    }
 
    
    //MARK: Touch response 
    
    
    private func touchDelay(){
        
        self.isUserInteractionEnabled = false
        isTouchDelayed = true
        print("cell interaction delayed.")
        let delayInSeconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
            self.enableTouch()
        }
    }
    
    
    
    func enableTouch() {
        self.isUserInteractionEnabled = true
        isTouchDelayed = false
        print("cell interaction enabled.")
    }
    

}
