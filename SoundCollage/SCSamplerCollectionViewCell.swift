
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupLabel() {
        padLabel.frame = .zero
        padLabel.text = "\(self.idx+1)"
        padLabel.textAlignment = NSTextAlignment.center
        padLabel.font = UIFont.init(name: "A DAY WITHOUT SUN", size: 60.0)
        padLabel.textColor = self.cellColor
        contentView.addSubview(padLabel)
        padLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.75, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        let centerY = ((contentView.frame.height/4)*3)/4
        self.contentView.addConstraint(NSLayoutConstraint.init(item: padLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: centerY))
    }
    
    
    func showIndicator(){
        
        padLabel.isHidden = true
        let indicator = UIImageView.init(image: UIImage.init(named: "spinner"))
        contentView.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
         contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 0.5, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.5, constant: 0))
        SCAnimator.RotateLayer(layer: indicator.layer, completion: {
            [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.padLabel.isHidden = false
            strongSelf.startRecording()
        })
        
    }
    
    
    func startRecording(){
        switch SCAudioManager.shared.isRecording {
        case true:
            print("Audio recording already in session.")
        case false:
            print("Started recording on sampler pad \(SCAudioManager.shared.selectedSampleIndex)")
            recordNewSample()
            self.isRecordingEnabled = false
        }
    }

    
    
    //MARK: Colors/animations
    
    
    
    
    func animateCell(){
        
        transformSize()
        let fromColor = UIColor.white.cgColor
        guard let toColor = self.cellColor?.cgColor else {
            print("No cell toColor.")
            return
        }
        self.padLabel.textColor = UIColor.white
        self.layer.borderColor = UIColor.white.cgColor
        let animation = CABasicAnimation.init(keyPath: "backgroundColor")
        animation.fromValue = fromColor
        animation.toValue = toColor
        animation.duration = 0.3
        animation.isRemovedOnCompletion = true
        animation.fillMode = kCAFilterLinear
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.delegate = self
        self.layer.add(animation, forKey: "backgroundColor")
        
    }
    
 
    
    func transformSize(){
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        })
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag == true {
            guard let color = self.cellColor else {return}
            self.layer.borderColor = color.cgColor
            self.padLabel.textColor = color
        }
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
            strongSelf.animateCell()
        }
    }
    
    
    
    func stopCellsFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
    }
    
    //MARK: Playback
    
    
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
    
    
    
    
    func isRecordingTouchDelay() {
        self.isUserInteractionEnabled = false
        isTouchDelayed = true
    }
    
    
    
    
    func enableTouch() {
        self.isUserInteractionEnabled = true
        isTouchDelayed = false
    }
    
    
}
