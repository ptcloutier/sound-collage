
//
//  SamplerCollectionViewCell.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit


class SCSamplerCollectionViewCell: UICollectionViewCell, AVAudioPlayerDelegate, CAAnimationDelegate {
    
    var idx: Int = 0
    var cellColor: UIColor?
    var isRecordingEnabled = false
    var isEditingEnabled = false
    var flashTimer: Timer? = nil
    var touchTimer: Timer? = nil
    var isTouchDelayed: Bool = false
    var padLabel: UILabel = UILabel()
    var colors = [[UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]]
    var gradientColors: SCColor?
    var doXAnimation: Bool = false 
    var doWaveAnimation: Bool = true
    var videoURL: URL?
    // Sprite
    var scene: PCScene!
    var size: CGSize!
    var skView = SKView()
    var spritePoint = CGPoint()

    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        skView = SKView.init(frame: self.bounds)
        self.contentView.addSubview(skView)
        size = self.contentView.frame.size
        scene = PCScene(size: size)
        skView.presentScene(scene)
        spritePoint = CGPoint.init(x: 50, y:50)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func circularCell(){
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.contentView.frame.width*0.1
    }
    
    
    func diamondCell(){
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.contentView.frame.width*1.0
    }
    
   
    
    func setupGIFView(){
        let v = self.contentView
        guard let url = videoURL else { return }
        do {
            let gif = try Data(contentsOf: url)
            let wv = UIWebView(frame: v.frame)
            wv.load(gif, mimeType: "image/gif", textEncodingName: "UTF-8", baseURL: NSURL() as URL)
            wv.isUserInteractionEnabled = false
            wv.scalesPageToFit = true
            wv.contentMode = .scaleToFill
            v.addSubview(wv)
            
            let filter = UIView()
            filter.frame = v.frame
            filter.backgroundColor = UIColor.black
            filter.alpha = 0.05
            v.addSubview(filter)
            
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }

    
    
    
    
    func setupLabel() {
        padLabel.addGlow(color: UIColor.white)
        padLabel.isUserInteractionEnabled = false
        padLabel.frame = self.contentView.frame
        padLabel.text = "\(self.idx+1)"
        padLabel.textAlignment = NSTextAlignment.center
        padLabel.font = UIFont.init(name: "Futura", size: 30.0)
        contentView.addSubview(padLabel)
        
    }
    
    
    
    func setupGradientColors() {
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
        scene.addShape(color: cellColor!, atLocation: spritePoint, rectWidth: 100.0)   //Sprite zone
        animateColor(fillMode: kCATransitionFade)
        flashTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] flashTimer in           // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.animateColor(fillMode: kCATransitionFade)
            strongSelf.scene.addShape(color: strongSelf.cellColor!, atLocation: strongSelf.spritePoint, rectWidth: 100.0)  //Sprite Zone
        }
    }

    


    func stopCellsFlashing() {
        if flashTimer != nil {
            flashTimer?.invalidate()
        }
    }
    
    
    
    func animateColor(fillMode: String) {
//        guard let gradientColors = self.gradientColors else { return }
//        gradientColors.morphColors(in: self, fillMode: fillMode)
        scene.addShape(color: cellColor!, atLocation: spritePoint, rectWidth: 100.0)   
    }

    
    
    
    //MARK: Recording/Playback
    
    
    
    
    func startRecording(){
        self.isRecordingEnabled = false
        switch SCAudioManager.shared.isRecordingSample {
        case true:
            print("Audio recording already in session.")
        case false:
            print("Started recording on sampler pad \(SCAudioManager.shared.selectedSampleIndex)")
            recordNewSample()
        }
    }
    
    

    func playbackSample() {
        SCAudioManager.shared.togglePlayer(index: self.idx)
        playbackTouchDelay()
    }
    
    
    
    
    func recordNewSample() {
        SCAudioManager.shared.recordNew()
    }
    
    
    
    
    //MARK: Touch response
    
    
    private func playbackTouchDelay(){
        
        if SCAudioManager.shared.isRecordingSample == false {
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
