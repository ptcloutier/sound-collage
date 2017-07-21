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
    var sequencerBar: UIView?
    var triggerCounter: Int = 0
    var triggerTimer: Timer?
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollectionView()
        setupSequencerBarUI()
        NotificationCenter.default.addObserver(self, selector: #selector(SCScoreViewController.playback), name: Notification.Name.init("sequencerPlaybackDidPress"), object: nil)
    }
    
    
    func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        scoreCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        scoreCV?.register(SCScoreCell.self, forCellWithReuseIdentifier: "SCScoreCell")
        guard let scoreCV = self.scoreCV else { return }
        scoreCV.delegate = self
        scoreCV.dataSource = self
        scoreCV.layer.borderWidth = 2.0
        scoreCV.layer.borderColor = UIColor.purple.cgColor
        view.addSubview(scoreCV)
        
        scoreCV.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))

    }
    
    
    
    func setupSequencerBarUI(){
        
        sequencerBar = UIView.init(frame: CGRect(x: 0, y: 0 , width: 3.0, height: view.frame.height))
        guard let sequencerBar = self.sequencerBar else { return }
        sequencerBar.backgroundColor = UIColor.white
        guard let scoreCV = self.scoreCV else { return }
        scoreCV.addSubview(sequencerBar)
        print("sequencer bar x:\(sequencerBar.frame.origin.x), y:\(sequencerBar.frame.origin.y), w:\(sequencerBar.frame.width), h:\(sequencerBar.frame.height)")
    }
    
    
   
    
    func startPlayerBarTimers(){
        guard sequencerTimer == nil else { return }
        guard triggerTimer == nil else { return }
        sequencerTimer = Timer.scheduledTimer(timeInterval: 8.0/16.0, target: self, selector: #selector(SCScoreViewController.triggerSample), userInfo: nil, repeats: true)
        RunLoop.main.add(sequencerTimer!, forMode: RunLoopMode.commonModes)
        triggerTimer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(SCScoreViewController.animateSequencerBarPosition), userInfo: nil, repeats: true)
        RunLoop.main.add(triggerTimer!, forMode: RunLoopMode.commonModes)
    }
    
    
    
    
    func triggerSample(){
        guard let sequencerBar = self.sequencerBar else { return }
        print("\(sequencerBar.frame.origin.x), \(sequencerBar.frame.origin.y)")
        var playbackSamples: [Int] = []
        print("trigger counter: \(triggerCounter)")
        for (index,settings) in SCAudioManager.shared.sequencerSettings[triggerCounter].enumerated() {
            if settings == true {
                playbackSamples.append(index)
            }
            
        }
        for sample in playbackSamples {
            SCAudioManager.shared.selectedSequencerIndex = sample
            SCAudioManager.shared.playAudio(sampleIndex: SCAudioManager.shared.selectedSequencerIndex)
        }
        if triggerCounter == 15 {
            triggerCounter = 0
        } else {
            triggerCounter+=1
        }
    }

    
    
    func animateSequencerBarPosition(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            guard let sequencerBar = self.sequencerBar else { return }
            let toPoint = CGPoint(x: UIScreen.main.bounds.width, y: 0)
            let fromPoint = CGPoint(x: 0, y: 0)
            let movement = CABasicAnimation.init(keyPath: "position")
            movement.isAdditive = true
            movement.fromValue = NSValue.init(cgPoint: fromPoint)
            movement.toValue = NSValue.init(cgPoint: toPoint)
            movement.duration = 8.0
            sequencerBar.layer.add(movement, forKey: "move")
        })
        
    }
    
  
    
    //MARK: Playback
    
    
    
    func playback(){
        
        switch self.isPlaying {
        case true:
            stopPlaying()
        case false:
            startPlaying()
        }
    }
    
    
    
    func startPlaying(){
        self.isPlaying = true
        setupSequencerBarUI()
        animateSequencerBarPosition()
        startPlayerBarTimers()
        print("Start sequencer.")
    }
    
    
    
    
    func stopPlaying(){
        guard triggerTimer != nil else { return }
        guard sequencerTimer != nil else { return }
        triggerTimer?.invalidate()
        triggerTimer = nil
        sequencerTimer?.invalidate()
        sequencerTimer = nil
        self.sequencerBar?.isHidden = true
        self.sequencerBar = nil
        self.triggerCounter = 0
        self.isPlaying = false
        print("stopped sequencer")

    }
}



extension SCScoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let result = CGSize.init(width: view.frame.width/16, height: view.frame.height/16)
//        return result
//    }
    
    
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
