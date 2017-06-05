
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
    var cellColor: UIColor?
    var currentColorSet: Int = 0
    var isRecordingEnabled = false
    var isEditingEnabled = false
    var flashTimer: Timer? = nil
    var touchTimer: Timer? = nil
    var isTouchDelayed: Bool = false
    var fromColors: [CGColor] = []
    var toColors: [CGColor] = []
    var animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
    var gradient = CAGradientLayer()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Gradient colors/animations
    
    
    
    func setRecordingColorSets() {
        
        colorSets.removeAll()
        let colors = [UIColor.red, UIColor.magenta, UIColor.orange]
        setColorSets(colors: colors)
    }
    
    
    func setEditingColorSets() {
        
        colorSets.removeAll()
        let colors = [UIColor.blue, UIColor.cyan, UIColor.magenta]
        setColorSets(colors: colors)
    }
    
    
    func setColorSets(colors: [UIColor]){
        
        guard let color = cellColor else {
            print("Color not found.")
            return
        }
        colorSets.append([color, color, color])
        colorSets.append(colors)
        fromColors = colorSets[currentColorSet].map {$0.cgColor}
        currentColorSet = 0
    }
    
    
    func setupGradientLayer() {
        
        
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
        playbackTouchDelay()
    }
    
    
    
    func recordNewSample() {
        SCAudioManager.shared.recordNew()
    }
 
    
    
    //MARK: Touch response 
    
    
    private func playbackTouchDelay(){
        
        if SCAudioManager.shared.isRecording == false {
            self.isUserInteractionEnabled = false
            isTouchDelayed = true
            print("cell interaction delayed.")
            let delayInSeconds = 0.001
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                self.enableTouch()
            }
        }
    }
    
    
    
    
    func isRecordingTouchDelay() {
        self.isUserInteractionEnabled = false
        isTouchDelayed = true
        print("cell interaction delayed.")
    }
    
    
    
    
    func enableTouch() {
        self.isUserInteractionEnabled = true
        isTouchDelayed = false
        print("cell interaction enabled.")
    }
    

}
