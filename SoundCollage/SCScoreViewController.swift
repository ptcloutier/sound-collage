//
//  SCScoreViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCScoreViewController: UIViewController {
    
    var scoreCV: UICollectionView?
    let toolbarHeight = CGFloat(98.0)
    var toolbar = UIToolbar()
    var recordBtn: UIButton?
    var sequencerTimer: Timer?
    var sequencerBar = UIView()
    var triggerCounter: Int = 1
    var triggerTimer: Timer?
    var timeSignature: Double = 4.0
    let margin: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCollectionView()
        setupSequencerBarUI()
        NotificationCenter.default.addObserver(self, selector: #selector(SCScoreViewController.playback), name: Notification.Name.init("sequencerPlaybackDidPress"), object: nil)
    }
    
    //MARK: UI setup
    
    func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        scoreCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        scoreCV?.register(SCScoreCell.self, forCellWithReuseIdentifier: "SCScoreCell")
        guard let scoreCV = self.scoreCV else { return }
        scoreCV.delegate = self
        scoreCV.dataSource = self
//        scoreCV.layer.borderWidth = 2.0
//        scoreCV.layer.borderColor = UIColor.purple.cgColor
        view.addSubview(scoreCV)
        
        scoreCV.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant:-margin))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: margin))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))
        
    }
    
    
    
    func setupSequencerBarUI(){
        sequencerBar.isHidden = true
        sequencerBar.frame = CGRect(x: 0, y: 0 , width: 3.0, height: view.frame.height)
        sequencerBar.backgroundColor = UIColor.white
        guard let scoreCV = self.scoreCV else { return }
        scoreCV.addSubview(sequencerBar)
        
        print("sequencer bar x:\(sequencerBar.frame.origin.x), y:\(sequencerBar.frame.origin.y), w:\(sequencerBar.frame.width), h:\(sequencerBar.frame.height)")
    }
    
    
    //MARK: Playback
    
    
    
    func playback(){
        
        switch SCAudioManager.shared.sequencerIsPlaying {
        case true:
            stopPlaying()
        case false:
            startPlaying()
        }
    }
    
    
    
    
    func startPlaying(){
        self.sequencerBar.isHidden = false
        SCAudioManager.shared.sequencerIsPlaying = true
        startPlayerBarTimers()
        animateSequencerBarPosition()
        print("Start sequencer.")
    }
    
    
    
    
    func stopPlaying(){
        guard triggerTimer != nil else { return }
        guard sequencerTimer != nil else { return }
        triggerTimer?.invalidate()
        triggerTimer = nil
        sequencerTimer?.invalidate()
        sequencerTimer = nil
        self.sequencerBar.isHidden = true
        self.triggerCounter = 0
        SCAudioManager.shared.sequencerIsPlaying = false
        print("stopped sequencer")
        
    }
    
    //MARK: Timers/Animation
    
    
    func startPlayerBarTimers(){
        
        guard sequencerTimer == nil else { return }
        guard triggerTimer == nil else { return }
        triggerSample()
        sequencerTimer = Timer.scheduledTimer(timeInterval: timeSignature/16.0, target: self, selector: #selector(SCScoreViewController.triggerSample), userInfo: nil, repeats: true)
        RunLoop.main.add(sequencerTimer!, forMode: RunLoopMode.commonModes)
        triggerTimer = Timer.scheduledTimer(timeInterval: timeSignature, target: self, selector: #selector(SCScoreViewController.animateSequencerBarPosition), userInfo: nil, repeats: true)
        RunLoop.main.add(triggerTimer!, forMode: RunLoopMode.commonModes)
    }
    
    
    
    
    func triggerSample(){
        
        print("\(sequencerBar.frame.origin.x), \(sequencerBar.frame.origin.y)")
        var playbackSamples: [Int] = []
        print("trigger counter: \(triggerCounter)")
        
        let samples = SCAudioManager.shared.sequencerSettings[triggerCounter]
        for (index,settings) in samples.enumerated() {
            if settings == true {
                playbackSamples.append(index)
            }
            
        }
        for sample in playbackSamples {
            SCAudioManager.shared.selectedSequencerIndex = sample
            SCAudioManager.shared.playAudio(sampleIndex: SCAudioManager.shared.selectedSequencerIndex)
        }
        if triggerCounter == 16 {
            triggerCounter = 1
        } else {
            triggerCounter+=1
        }
    }
    
    
    
    func animateSequencerBarPosition(){
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            let toPoint = CGPoint(x: UIScreen.main.bounds.width, y: 0)
            let fromPoint = CGPoint(x: self.view.frame.width/17, y: 0)
            let movement = CABasicAnimation.init(keyPath: "position")
            movement.isAdditive = true
            movement.fromValue = NSValue.init(cgPoint: fromPoint)
            movement.toValue = NSValue.init(cgPoint: toPoint)
            movement.duration = self.timeSignature
            self.sequencerBar.layer.add(movement, forKey: "move")
        })
    }
}



extension SCScoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = scoreCV?.dequeueReusableCell(withReuseIdentifier: "SCScoreCell", for: indexPath) as!SCScoreCell
        cell.setupSequencer()
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
