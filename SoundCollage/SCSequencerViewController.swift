//
//  SCSequencerViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 9/5/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation



class SCSequencerViewController: UIViewController {

    var sequencer: UICollectionView?
    var recordBtn: UIButton?
    var sequencerTimer: Timer?
    var sequencerBar = UIView()
    var triggerCounter: Int = 0
    var triggerTimer: Timer?
    var timeSignature: Double = 4.0
    let margin: CGFloat = 10.0
    let toolbarHeight = CGFloat(49.0)
    let navBarBtnFrameSize = CGRect.init(x: 0, y: 0, width: 30, height: 30)
    var toolbar = SCToolbar()
    var sampler: SCSamplerViewController?
    var avplayer: AVPlayer = AVPlayer()
    var videoView = UIView()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SCColor.Custom.Gray.dark
        setupVideoView()
        setupSequencer()
        setupSequencerBarUI()
        NotificationCenter.default.addObserver(self, selector: #selector(SCSequencerViewController.playback), name: Notification.Name.init("sequencerPlaybackDidPress"), object: nil)
        setupControls()
        setupSampler()
        toggleSelectedVC(index: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(SCSequencerViewController.touch(notification:)), name: NSNotification.Name(rawValue: "sequencerTouchNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCSequencerViewController.showSequencer(notification:)), name: NSNotification.Name(rawValue: "showSequencerNotification"), object: nil)
        
        
        }
    
       /*
     //Config dark gradient view
     CAGradientLayer *gradient = [CAGradientLayer layer];
     gradient.frame = [[UIScreen mainScreen] bounds];
     gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0x030303) CGColor], (id)[[UIColor clearColor] CGColor], (id)[UIColorFromRGB(0x030303) CGColor],nil];
     [self.gradientView.layer insertSublayer:gradient atIndex:0];
     } */
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.avplayer.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.avplayer.play()
    }
    
    
    
    //MARK: AVPlayer methods
    
    func setupVideoView(){
        
        self.videoView = UIView.init(frame: view.frame)
        guard let path = Bundle.main.path(forResource: "1080p", ofType: "mov") else { return }
        let videoURL = URL.init(fileURLWithPath: path)
        let avasset = AVAsset.init(url: videoURL)
        let avPlayerItem = AVPlayerItem.init(asset: avasset)
        self.avplayer = AVPlayer.init(playerItem: avPlayerItem)
        let avPlayerLayer = AVPlayerLayer.init(player: avplayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayerLayer.frame = UIScreen.main.bounds
        self.videoView.layer.addSublayer(avPlayerLayer)
        
        self.avplayer.seek(to: kCMTimeZero)
        avplayer.volume = 0.0
        avplayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(SCSequencerViewController.playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCSequencerViewController.playerStartPlaying), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.view.addSubview(videoView)
        self.view.sendSubview(toBack: videoView)
    }
    
    
    
    func playerStartPlaying(){
        self.avplayer.play()
    }
    
    
    func playerItemDidReachEnd(notification: Notification){
        
        guard let p: AVPlayerItem = notification.object as? AVPlayerItem else { return }
        p.seek(to: kCMTimeZero)
    }
    
    
    
    //MARK: UI setup
    
    func setupSequencer() {
        let frame = CGRect(x: margin, y: margin*2.0, width: self.view.frame.width-(margin*2.0), height: view.frame.height-toolbarHeight-(margin*2.0))
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        sequencer = UICollectionView.init(frame: frame, collectionViewLayout: flowLayout)
        guard let sequencer = self.sequencer else { return }
        sequencer.register(SCScoreCell.self, forCellWithReuseIdentifier: "SCScoreCell")
        sequencer.delegate = self
        sequencer.dataSource = self
        view.addSubview(sequencer)
    }
    
    
    func setupSampler(){
        
        self.sampler = SCSamplerViewController(nibName: nil, bundle: nil)
        guard let samplerVC = self.sampler else { return }
        samplerVC.view.frame = CGRect(x: margin, y: margin, width: self.view.frame.width, height: self.view.frame.height/1.83)
        samplerVC.view.center = view.center
        self.view.addSubview(samplerVC.view)
    }

    
    func setupSequencerBarUI() {
        
        sequencerBar.isHidden = true
        sequencerBar.frame = CGRect(x: 0, y: 0 , width: 3.0, height: view.frame.height)
        sequencerBar.backgroundColor = SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet
        guard let sequencer = self.sequencer else { return }
        sequencer.addSubview(sequencerBar)
        
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
        sequencerTimer = Timer.scheduledTimer(timeInterval: timeSignature/16.0, target: self, selector: #selector(SCSequencerViewController.triggerSample), userInfo: nil, repeats: true)
        RunLoop.main.add(sequencerTimer!, forMode: RunLoopMode.commonModes)
        triggerTimer = Timer.scheduledTimer(timeInterval: timeSignature, target: self, selector: #selector(SCSequencerViewController.animateSequencerBarPosition), userInfo: nil, repeats: true)
        RunLoop.main.add(triggerTimer!, forMode: RunLoopMode.commonModes)
    }
    
    
    
    
    func triggerSample(){
        
        print("\(sequencerBar.frame.origin.x), \(sequencerBar.frame.origin.y)")
        var playbackSamples: [Int] = []
        print("trigger counter: \(triggerCounter)")
        
        guard let score = SCDataManager.shared.user?.sampleBanks[(SCDataManager.shared.currentSampleBank)!].sequencerSettings?.score  else {
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
            SCAudioManager.shared.audioController?.togglePlayer(index: sample)
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

    //MARK: ui setup
    
    
    private func setupControls(){
        
        toolbar.transparentToolbar(view: view, toolbarHeight: toolbarHeight)
        let buttonHeight = (toolbarHeight/3)*2
        
        self.recordBtn = UIButton.GradientColorStyle(height: buttonHeight, gradientColors: [UIColor.red, UIColor.magenta, UIColor.orange], secondaryColor: UIColor.white)
        
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        recordBtn.addGlow(color: SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral)
        recordBtn.setBackgroundImage(UIImage.init(named: "record"), for: .normal)
        recordBtn.addTarget(self, action: #selector(SCSequencerViewController.recordBtnDidPress), for: .touchUpInside)
        
        let bankBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        bankBtn.setBackgroundImage(UIImage.init(named: "sampleBank"), for: .normal)
        bankBtn.addTarget(self, action: #selector(SCSequencerViewController.bankBtnDidPress), for: .touchUpInside)
        bankBtn.addGlow(color: UIColor.white)
        
        let sequencerBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        sequencerBtn.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
        sequencerBtn.addTarget(self, action: #selector(SCSequencerViewController.postSequencerPlaybackDidPressNotification), for: .touchUpInside)
        sequencerBtn.addGlow(color: UIColor.white)
        
        let libraryBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        libraryBtn.setBackgroundImage(UIImage.init(named: "playlist"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(SCSequencerViewController.libraryBtnDidPress), for: .touchUpInside)
        libraryBtn.addGlow(color: UIColor.white)
        
        let recordNewSCBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        recordNewSCBtn.setBackgroundImage(UIImage.init(named: "lp1"), for: .normal)
        recordNewSCBtn.addTarget(self, action: #selector(SCSequencerViewController.recordMixerOutputBtnDidPress), for: .touchUpInside)
        recordNewSCBtn.addGlow(color: UIColor.white)
        
        let bankBarBtn = UIBarButtonItem.init(customView: bankBtn)
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        let sequencerBarBtn = UIBarButtonItem.init(customView: sequencerBtn)
        let libraryBarBtn = UIBarButtonItem.init(customView: libraryBtn)
        let recordNewSCBarBtn = UIBarButtonItem.init(customView: recordNewSCBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [ flexibleSpace, bankBarBtn, flexibleSpace, sequencerBarBtn, flexibleSpace,  recordBarBtn, flexibleSpace,  libraryBarBtn, flexibleSpace, recordNewSCBarBtn, flexibleSpace ]
        self.view.addSubview(toolbar)
        toolbar.backgroundColor = SCColor.Custom.Gray.dark
    }
    
    
    //MARK: Navigation
    
    
    func recordBtnDidPress(){
        
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        postRecordBtnDidPressNotification()
        
        switch SCAudioManager.shared.isRecording {
        case true:
            SCAudioManager.shared.audioController?.isRecordingSelected = false
            SCAudioManager.shared.stopRecordingSample()
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        case false:
            SCAudioManager.shared.audioController?.engine?.pause()
            SCAudioManager.shared.audioController?.isRecordingSelected = true
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        }
    }
    
    
    
    
    func bankBtnDidPress(){
        
        SCAudioManager.shared.audioController?.engine?.pause()
        SCAudioManager.shared.audioController?.engine?.reset()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    func libraryBtnDidPress(){
        
        print("library button pressed.")
        let vc: SCLibraryViewController = SCLibraryViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    func recordMixerOutputBtnDidPress(){
        
        print("new recording sound collage did press.")
        
        switch SCAudioManager.shared.isRecordingMixerOutput {
        case true:
            SCAudioManager.shared.audioController?.stopRecordingMixerOutput()
            SCAudioManager.shared.isRecordingMixerOutput = false
        case false:
            SCAudioManager.shared.audioController?.startRecordingMixerOutput()
            SCAudioManager.shared.isRecordingMixerOutput = true
        }
    }
    
    
    
    //MARK: Notifications
    
    
    func postRecordBtnDidPressNotification(){
        
        NotificationCenter.default.post(name: Notification.Name.init("recordBtnDidPress"), object: nil)
        NotificationCenter.default.post(name: Notification.Name.init("ScrollToSamplerNotification"), object: nil)
    }
    
    
    
    func postSequencerPlaybackDidPressNotification(){
        
        NotificationCenter.default.post(name: Notification.Name.init("sequencerPlaybackDidPress"), object: nil)
    }
    
    
    
    //MARK: focus/darken vc's
    
    func touch(notification: Notification){
        
        if let touchLocation = notification.userInfo?["touchLocation"] as? CGPoint {
        
        if touchLocation.y < 75.0 {
            
            toggleSelectedVC(index: 0)
        }
        if touchLocation.y > 550.0 {
            toggleSelectedVC(index: 1)
        }
        print("touch at : \(touchLocation.x), \(touchLocation.y)")
        }
    }

    
    
    func showSequencer(notification: Notification){
        
        if let index = notification.userInfo?["index"] as? Int {
            toggleSelectedVC(index: index)
        }
    }
    
    
    
    func toggleSelectedVC(index: Int){
        
        guard let sequencer = self.sequencer else {
            return
        }
        guard let sampler = self.sampler?.view else{
            return
        }
       
        
        switch index {
        case 0:
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations:{
                sequencer.alpha = 1.0
                sampler.alpha = 0.3
                self.view.bringSubview(toFront: sampler)
                sequencer.isUserInteractionEnabled = true
                sampler.isUserInteractionEnabled = false
            })
            break
        case 1:
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations:{
                sampler.alpha = 1.0
                sequencer.alpha = 0.1
                self.view.bringSubview(toFront: sequencer)
                sequencer.isUserInteractionEnabled = false
                sampler.isUserInteractionEnabled = true
            })
            break
        default:
            print("")
        }
    }
}







extension SCSequencerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize.init(width: collectionView.frame.size.width, height: self.view.frame.height-toolbarHeight-20.0)
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



extension SCSequencerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sequencer?.dequeueReusableCell(withReuseIdentifier: "SCScoreCell", for: indexPath) as!SCScoreCell
        cell.setupSequencer()
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

 
