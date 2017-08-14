//
//  SCScoreViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCScoreViewController: UIViewController {
    
    var cvHeight: CGFloat = 368.0
    var scoreCV: UICollectionView?
    let toolbarHeight = CGFloat(98.0)
    var toolbar = UIToolbar()
    var recordBtn: UIButton?
    var sequencerTimer: Timer?
    var sequencerBar = UIView()
    var triggerCounter: Int = 0
    var triggerTimer: Timer?
    var timeSignature: Double = 4.0
    let margin: CGFloat = 10.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SCColor.Custom.Gray.dark
        setupCollectionView()
        setupSequencerBarUI()
        NotificationCenter.default.addObserver(self, selector: #selector(SCScoreViewController.playback), name: Notification.Name.init("sequencerPlaybackDidPress"), object: nil)
    }
    
    
    //MARK: UI setup
    
    func setupCollectionView() {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: cvHeight)
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        scoreCV = UICollectionView.init(frame: frame, collectionViewLayout: flowLayout)
        scoreCV?.register(SCScoreCell.self, forCellWithReuseIdentifier: "SCScoreCell")
        guard let scoreCV = self.scoreCV else { return }
        scoreCV.delegate = self
        scoreCV.dataSource = self
        view.addSubview(scoreCV)
        
                
    }
    
    
    
    func setupSequencerBarUI() {
        
        sequencerBar.isHidden = true
        sequencerBar.frame = CGRect(x: 0, y: 0 , width: 3.0, height: view.frame.height)
        sequencerBar.backgroundColor = SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet
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
        
        guard let score = SCDataManager.shared.user?.sampleBanks?[(SCDataManager.shared.user?.currentSampleBank)!].sequencerSettings?.score  else {
            print("Error, no score.")
            return
        }
        
        let samples = score[triggerCounter]
        for (index,settings) in samples.enumerated() {
            if settings == true {
                playbackSamples.append(index)
            }
            
        }
        for sample in playbackSamples {
            SCAudioManager.shared.selectedSequencerIndex = sample
            SCAudioManager.shared.audioController?.togglePlayer(index: SCAudioManager.shared.selectedSequencerIndex)
        }
        if triggerCounter == 15 {
            triggerCounter = 0
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


extension SCScoreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize.init(width: collectionView.frame.size.width, height: self.cvHeight)
        print("cellSize - \(cellSize.width), \(cellSize.height)")
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}



extension SCScoreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
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
