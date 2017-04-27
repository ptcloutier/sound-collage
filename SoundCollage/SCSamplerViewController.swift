//
//  SamplerViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation
//import AudioKit



class SCSamplerViewController: UIViewController  {
    
    var collectionView: UICollectionView?
    var recordBtn = UIButton()
    var newRecordingTitle: String?
    var audioPlayer: SCAudioManager!
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!
    var speakerBtn = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupControls()
        animateEntrance()
        view.backgroundColor = UIColor.darkGray

        
        let navBar = UINavigationBar.init(frame:CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: 50 ))
        navBar.tintColor = UIColor.black
        self.view.addSubview(navBar)
        
        
        let navItem = UINavigationItem()
        
        let speakerButton = UIButton.init(type: .custom)
        speakerButton.setImage(UIImage.init(named: "speakerOff"), for: .normal)
        speakerButton.addTarget(self, action: #selector(SCSamplerViewController.audioPlaybackSource), for: .touchUpInside)
        speakerButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        self.speakerBtn = speakerButton
        let barButton = UIBarButtonItem(customView: self.speakerBtn)
        navItem.rightBarButtonItem = barButton
        navBar.items = [navItem]
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 
        guard let collectionView = self.collectionView else {
            print("collectionview is nil")
            return
        }
        collectionView.bounds.size = collectionView.collectionViewLayout.collectionViewContentSize
        collectionView.frame.origin.y = 80
    }
    
    
    
    private func setupCollectionView(){
        let flowLayout = SCSamplerFlowLayout()
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        guard let collectionView = self.collectionView else{
            print("Error: collectionview is nil")
            return
        }
        collectionView.register(SCSamplerCollectionViewCell.self, forCellWithReuseIdentifier: "SCSamplerCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
    }
    
    
    
    private func setupControls(){
        
        recordBtn.setBackgroundImage(UIImage.init(named: "record"), for: .normal)
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        
        
        let tabHeight = CGFloat(49.0)
        let buttonHeight = view.frame.width/6
        let yPosition = view.frame.height-tabHeight-buttonHeight
        recordBtn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        recordBtn.center = CGPoint(x: view.center.x, y: yPosition)
        view.addSubview(recordBtn)
    }
    
    
    
    //MARK: Animations
    
    
    
    private func animateEntrance() {
    
        view.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.5, options: [.curveEaseInOut], animations:{
            self.view.alpha = 1
            }, completion: nil)
    }

    
    func audioPlaybackSource(){
        
        //TODO: duplicate buttons are created
        
        switch SCAudioManager.shared.isSpeakerEnabled {
        case true:
            speakerBtn.setBackgroundImage(UIImage.init(named: "speakerOn"), for: .normal)
            
        case false:
            speakerBtn.setBackgroundImage(UIImage.init(named: "speakerOff"), for: .normal)

        }
        SCAudioManager.shared.playbackSource()
    }
    
    
    
    
    //MARK: Recording and Playback
    
    
    
    
    func recordBtnDidPress(){
        
        switch SCAudioManager.shared.isRecording {
        case true:
            print("Audio recording stopped.")
            SCAudioManager.shared.finishRecording(success: true)
            reloadCV()
        case false:
            recordingMode()
        }
    }
    
    func reloadCV() {
        guard let cv = self.collectionView else {
            print("collectionview not found.")
            return
        }
        cv.reloadData()
    }
    

    func recordingMode() {
        
        // toggle recording mode
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            SCAudioManager.shared.isRecordingModeEnabled = false
        case false:
            SCAudioManager.shared.isRecordingModeEnabled = true
        }
        reloadCV()
    }


    func audioSessionRecordingState(in cell: SCSamplerCollectionViewCell,samplePadIndex: Int){
        switch SCAudioManager.shared.isRecording {
        case true:
            print("Audio recording in session.")
        case false:
            print("Started recording on sampler pad \(samplePadIndex)")
            SCAudioManager.shared.createNewSample()
            cell.isEnabled = false
            recordingMode()
        }
    }
}


extension SCSamplerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSamplerCollectionViewCell", for: indexPath) as! SCSamplerCollectionViewCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15.0
        // add a border
        cell.layer.borderColor = UIColor.cyan.cgColor
        cell.layer.borderWidth = 3.0
        cell.layer.cornerRadius = 15.0
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            cell.isEnabled = true
            cell.startCellsFlashing()
          
        case false:
            cell.isEnabled = false
            cell.stopCellsFlashing()
        }
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCSamplerCollectionViewCell else {
            fatalError("Wrong cell dequeued")
        }
        SCAudioManager.shared.selectedSampleIndex = indexPath.row
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            audioSessionRecordingState(in: cell, samplePadIndex: indexPath.row)
        case false:
            SCAudioManager.shared.playback()
            cell.animateCellForPlayback()
        }

    }
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
