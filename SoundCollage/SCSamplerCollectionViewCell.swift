
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
    
    
    var cellColor: UIColor?
    var isRecordingEnabled = false
    var isEditingEnabled = false
    var flashTimer: Timer? = nil
    var touchTimer: Timer? = nil
    var isTouchDelayed: Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Colors/animations
    
    
    
    
    func animateCell(){
        
        transformSize()
        let fromColor = UIColor.white.cgColor
        guard let toColor = self.cellColor?.cgColor else {
            print("No cell toColor.")
            return
        }
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
