
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
    let colors = [[UIColor.black.cgColor, UIColor.purple.cgColor, UIColor.black.cgColor], [UIColor.red.cgColor, UIColor.magenta.cgColor, UIColor.orange.cgColor]]
    var gradientColors: SCColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupLabel() {

        padLabel.isUserInteractionEnabled = false
        padLabel.frame = .zero
        padLabel.text = "\(self.idx+1)"
        padLabel.textAlignment = NSTextAlignment.center
        padLabel.font = UIFont.init(name: "Futura", size: 20.0)
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        
        contentView.addSubview(padLabel)
        padLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.75, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        let centerY = ((contentView.frame.height/4)*3)/4
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: centerY))
        
        gradientColors = SCColor.init(colors: colors)
        guard let gradientColors = self.gradientColors else { return }
        gradientColors.configureGradientLayer(in: self.contentView, from: CGPoint.init(x: 0, y: 0), to: CGPoint.init(x: 1, y: 1))
    }
    

    
    //MARK: Animations
    
    func startCellFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
        startTimer()
    }
    
    
    
    func startTimer() {
        
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) {
            [weak self] flashTimer in  // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.animateCell()
        }
    }
    
    
    
    func stopCellsFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
    }
    
    
    
    
    
    func animateCell(){
        
        animateColor()
    }
    
    
    
    func animateColor(){
        guard let gradientColors = self.gradientColors else { return }
        gradientColors.morphColors(in: self)
       
//
//        UIView.animate(withDuration: 0.05, animations: {
//            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
////            let colors = [UIColor.red, UIColor.magenta, UIColor.orange]
////            self.applyGradient(withColors: colors, gradientOrientation: .topLeftBottomRight)
//        }, completion: { _ in
//            UIView.animate(withDuration: 0.05, animations: {
//                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
////                self.backgroundColor = UIColor.black
//                
//            })
//        })
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
        
        SCAudioManager.shared.playAudio(sampleIndex: SCAudioManager.shared.selectedSampleIndex)
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
