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
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    var speakerBtn = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupControls()
        animateEntrance()
        
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
    
    // MARK: UI Gradient Colors
    
    private func setupCollectionView(){
        let flowLayout = SCSamplerFlowLayout()
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        guard let collectionView = self.collectionView else{
            print("Error: collectionview is nil")
            return
        }
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsMultipleSelection = true
        collectionView.register(SCSamplerCollectionViewCell.self, forCellWithReuseIdentifier: "SCSamplerCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
    }
    
    
    
    private func setupControls(){
        

        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        
        let tabHeight = CGFloat(49.0)
        let buttonHeight = view.frame.width/4
        let yPosition = view.frame.height-tabHeight-buttonHeight
        recordBtn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        
        let backgroundView = UIView.init(frame: recordBtn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.applyGradient(withColors: [UIColor.red, UIColor.magenta, UIColor.orange], gradientOrientation: .topLeftBottomRight)
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.borderWidth = 2.0
        backgroundView.layer.borderColor = UIColor.white.cgColor
        
        recordBtn.addSubview(backgroundView)
        recordBtn.center = CGPoint(x: view.center.x, y: yPosition)
        
        view.addSubview(recordBtn)
        
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        let navBar = UINavigationBar.init(frame:CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: 50 ))
        navBar.setBackgroundImage(transparentPixel, for: UIBarMetrics.default)
        navBar.shadowImage = transparentPixel
        navBar.isTranslucent = true
        self.view.addSubview(navBar)
        
        
        let navItem = UINavigationItem()
        
        let speakerButton = UIButton.init(type: .custom)
        speakerButton.setImage(UIImage.init(named: "speakerOff"), for: .normal)
        speakerButton.setImage(UIImage.init(named: "speakerOn"), for: .selected)
        speakerButton.addTarget(self, action: #selector(SCSamplerViewController.audioPlaybackSource), for: .touchUpInside)
        speakerButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        self.speakerBtn = speakerButton
        let barButton = UIBarButtonItem(customView: self.speakerBtn)
        navItem.rightBarButtonItem = barButton
        navBar.items = [navItem]

    }
    
    
    
    //MARK: Animations
    
    
    
    private func animateEntrance() {
    
        view.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.5, options: [.curveEaseInOut], animations:{
            self.view.alpha = 1
            }, completion: nil)
    }

    
    func audioPlaybackSource(){
        
        SCAudioManager.shared.playbackSource()

        switch SCAudioManager.shared.isSpeakerEnabled {
        case true:
            speakerBtn.isSelected = true
        case false:
            speakerBtn.isSelected = false
        }
    }
    
    
    
    
    //MARK: Recording and Playback
    
    
    
    
    func recordBtnDidPress(){
        
        switch SCAudioManager.shared.isRecording {
        case true:
            SCAudioManager.shared.finishRecording(success: true)
            reloadCV()
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                self.recordBtn.alpha = 1
            }, completion: nil)
        case false:
            recordingMode()
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                self.recordBtn.alpha = 1
            }, completion: nil)
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


    func startRecording(in cell: SCSamplerCollectionViewCell,samplePadIndex: Int){
        switch SCAudioManager.shared.isRecording {
        case true:
            print("Audio recording in session.")
        case false:
            print("Recording in progress on sampler pad \(samplePadIndex)")
            cell.recordNewSample()
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
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2.0
        cell.layer.cornerRadius = 15.0
        //shadow
        cell.layer.shadowColor = UIColor.darkGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.layer.shadowOpacity = 0.7
        cell.layer.shadowRadius = 3.0
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(SCSamplerViewController.tap(gestureRecognizer:)))
        tapGR.delegate = self
        cell.addGestureRecognizer(tapGR)
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            cell.isEnabled = true
            cell.startCellFlashing()
            print("Recording is enabled in cell \(indexPath.row)")
          
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
            if cell.isTouchDelayed == false {
                startRecording(in: cell, samplePadIndex: indexPath.row)
            } else {
                print("extraneous cell touch was delayed.")
            }
        case false:
            if cell.isTouchDelayed == false {
                cell.playbackSample()
                cell.animateCellForPlayback()
            } else {
                print("extraneous cell touch was delayed.")
            }
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            }
        }
        return true
    }
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension SCSamplerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func tap(gestureRecognizer: UITapGestureRecognizer) {
        let tapLocation = gestureRecognizer.location(in: self.collectionView)
        
        //using the tapLocation to get the indexPath
        guard let collectionView = self.collectionView else {
            print("CollectionView not found.")
            return
        }
        guard let indexPath = collectionView.indexPathForItem(at: tapLocation) else {
            print("indexPath not found.")
            return
        }
        
        //now we can get the cell for item at indexPath
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            print("cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        //here we do whatever like play the desired sounds of the cells.
        print("selected cell at \(indexPath.row)")
        self.collectionView(collectionView!, didSelectItemAt: indexPath)

    }
}
