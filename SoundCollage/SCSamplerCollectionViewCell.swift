
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
    
    var idx: Int = 0
    var cellColor: UIColor?
    var isRecordingEnabled = false
    var isEditingEnabled = false
    var flashTimer: Timer? = nil
    var touchTimer: Timer? = nil
    var isTouchDelayed: Bool = false
    var padLabel: UILabel = UILabel()
    var colors = [[SCColor.Custom.Gray.dark.cgColor, SCColor.Custom.Gray.dark.cgColor, SCColor.Custom.Gray.dark.cgColor]]
    var gradientColors: SCColor?
    var doXAnimation: Bool = false 
    var doWaveAnimation: Bool = true

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupLabel() {

        padLabel.addGlow(color: self.cellColor!)
        padLabel.isUserInteractionEnabled = false
        padLabel.frame = self.contentView.frame
//        padLabel.text = "\(self.idx+1)"
        padLabel.textAlignment = NSTextAlignment.center
        padLabel.font = UIFont.init(name: "Futura", size: 20.0)
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.contentView.frame.width/2
        contentView.addSubview(padLabel)
    }
    
    
    
    func setupGradientColors(){
        
        if self.colors.count<2 {
            self.colors.append([(cellColor?.cgColor)!, (cellColor?.cgColor)!, (cellColor?.cgColor)!])
        }
        gradientColors = SCColor.init(colors: colors)
        guard let gradientColors = self.gradientColors else { return }
        gradientColors.configureGradientLayer(in: self.contentView, from: self.contentView.center, to: CGPoint.init(x: 1, y: 1))
    }

    
    //MARK: Animations
    
    func startCellFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
        startTimer()
    }
    
    
    
    func startTimer() {
        
        animateColor(fillMode: kCATransitionFade)

        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) {
            [weak self] flashTimer in  // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.animateColor(fillMode: kCATransitionFade)
        }
    }
    
    
    
    func stopCellsFlashing() {
        
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
    }
    
    
    
    func animateColor(fillMode: String) {
        
        guard let gradientColors = self.gradientColors else { return }
        gradientColors.morphColors(in: self, fillMode: fillMode)
    }

    
    
    
    //MARK: Recording/Playback
    
    
    
    
    
    func startRecording(){
        
        self.isRecordingEnabled = false
        
        switch SCAudioManager.shared.isRecording {
        case true:
            print("Audio recording already in session.")
        case false:
            print("Started recording on sampler pad \(SCAudioManager.shared.selectedSampleIndex)")
            recordNewSample()
        }
    }
    
    

    func playbackSample() {
        
        SCAudioManager.shared.audioController?.togglePlayer(index: self.idx)
//        SCAudioManager.shared.playAudio(senderID: 0)
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
            let delayInSeconds = 0.001
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                self.enableTouch()
            }
        }
    }
    
    
    
    
    func isRecordingDelayTouch() {
        self.isUserInteractionEnabled = false
        isTouchDelayed = true
    }
    
    
    
    
    func enableTouch() {
        self.isUserInteractionEnabled = true
        isTouchDelayed = false
    }
    
}
