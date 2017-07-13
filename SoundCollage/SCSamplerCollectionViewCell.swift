
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
//    var indicator = UIImageView()
    
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
        
        isRecordingEnabled = false
        startRecording()
//        self.contentView.backgroundColor = self.cellColor
//        padLabel.isHidden = true
//        indicator.image = UIImage.init(named: "spinner")
//        indicator.frame = CGRect(x: contentView.center.x-contentView.frame.width/4, y: contentView.center.y-contentView.frame.height/4, width: contentView.frame.width/2, height: contentView.frame.height/2)
//        indicator.center = self.contentView.center
//        contentView.addSubview(indicator)
//
//        SCAnimator.RotateLayer(layer: indicator.layer, completion: {
//            [weak self] _ in
//            guard let strongSelf = self else { return }
//            strongSelf.padLabel.isHidden = false
//            strongSelf.indicator.isHidden = true
//            strongSelf.contentView.backgroundColor = strongSelf.cellColor
//            strongSelf.contentView.layer.borderColor = UIColor.clear.cgColor
//            strongSelf.padLabel.textColor = UIColor.clear
//            strongSelf.startRecording()
//        })
    
    }
    
    
    func startRecording(){
        switch SCAudioManager.shared.isRecording {
        case true:
            print("Audio recording already in session.")
        case false:
            print("Started recording on sampler pad \(SCAudioManager.shared.selectedSampleIndex)")
            recordNewSample()
        }
    }

    
    
    //MARK: Colors/animations
    
    
    
    
    func animateCell(){
        
        transformSize()
        guard let toColor = self.cellColor else {
            print("No cell toColor.")
            return
        }
        UIView.animate(withDuration: 0.6, delay: 0, options: [.transitionCrossDissolve], animations:{
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundColor = toColor
            strongSelf.padLabel.textColor = UIColor.black
            strongSelf.layer.borderColor = UIColor.black.cgColor
            strongSelf.padLabel.isHidden = false
//            strongSelf.indicator.isHidden = true

        },
                       completion: { (finished: Bool) in
                        self.layer.borderColor = self.cellColor?.cgColor
                        self.padLabel.textColor = self.cellColor
                        self.backgroundColor = UIColor.clear
        })
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
