//
//  SamplerViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation



class SCSamplerViewController: UIViewController  {
    
    var collectionView: UICollectionView?
    let recordBtn = UIButton()
    var speakerBtn = UIButton()
    var newRecordingTitle: String?
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    let navBarBtnFrameSize = CGRect.init(x: 0, y: 0, width: 30, height: 30)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordingDidFinishNotification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.finishedRecording), name: recordingDidFinishNotification, object: nil)
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
    
    
    //MARK: Setup UI
    
    
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
        
        self.speakerBtn = UIButton.init(type: .custom)
        speakerBtn.setImage(UIImage.init(named: "speakerOff"), for: .normal)
        speakerBtn.setImage(UIImage.init(named: "speakerOn"), for: .selected)
        speakerBtn.addTarget(self, action: #selector(SCSamplerViewController.changeAudioPlaybackSource), for: .touchUpInside)
        speakerBtn.frame = navBarBtnFrameSize
        setAudioPlaybackSourceButton()
        let speakerBarBtn = UIBarButtonItem(customView: speakerBtn)
        

        let editorBtn = UIButton.init(type: .custom)
        editorBtn.setImage(UIImage.init(named: "wf"), for: .normal)
        editorBtn.frame = navBarBtnFrameSize
        editorBtn.addTarget(self, action: #selector(SCSamplerViewController.toggleEditingMode), for: .touchUpInside)
        let editorBarBtn = UIBarButtonItem(customView: editorBtn)
        
        navItem.rightBarButtonItems = [speakerBarBtn, editorBarBtn]
        navBar.items = [navItem]
    }
    
    
    
    //MARK: Animations
    
    
    
    private func animateEntrance() {
    
        view.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.5, options: [.curveEaseInOut], animations:{
            self.view.alpha = 1
            }, completion: nil)
    }

    
    
    func changeAudioPlaybackSource(){
        
        switch SCAudioManager.shared.isSpeakerEnabled {
        case true:
            SCAudioManager.shared.isSpeakerEnabled = false
        case false:
            SCAudioManager.shared.isSpeakerEnabled = true
        }
        SCAudioManager.shared.setAudioPlaybackSource()
        setAudioPlaybackSourceButton()
    }
    
    
    
    func setAudioPlaybackSourceButton(){
        
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
            toggleRecordingMode()
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
    
    

    func toggleRecordingMode() {
        
        let audioManager = SCAudioManager.shared
        switch audioManager.isRecordingModeEnabled {
        case true:
            audioManager.isRecordingModeEnabled = false
            print("Recording mode disabled.")
        case false:
            audioManager.isRecordingModeEnabled = true
            if audioManager.isEditingModeEnabled == true {
                audioManager.isEditingModeEnabled = false
                print("Editing mode disabled.")
            }
            print("Recording mode enabled.")
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
            cell.isRecordingEnabled = false
            toggleRecordingMode()
        }
    }

    
    
    func finishedRecording() {
       print("Recording finished.")
    }
    
    
    
    //MARK: Editing 
    
    func toggleEditingMode() {
        
        let audioManager = SCAudioManager.shared

        switch audioManager.isEditingModeEnabled {
        case true:
            audioManager.isEditingModeEnabled = false
            print("Editing mode disabled.")
        case false:
            audioManager.isEditingModeEnabled = true
            if audioManager.isRecordingModeEnabled == true {
                audioManager.isRecordingModeEnabled = false
                print("Recording mode disabled.")
            }
            print("Editing mode enabled.")
        }
        reloadCV()
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
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SCSamplerViewController.tap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        cell.addGestureRecognizer(tapGestureRecognizer)

        
        // Recording Mode
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            cell.isRecordingEnabled = true
        case false:
            cell.isRecordingEnabled = false
        }
        
        // Editing Mode
        switch SCAudioManager.shared.isEditingModeEnabled {
        case true:
            cell.isEditingEnabled = true
        case false:
            cell.isEditingEnabled = false
        }
        
        // Set colors for recording mode
        if SCAudioManager.shared.isEditingModeEnabled {
            cell.setEditingColorSets()
        } else {
            cell.setRecordingColorSets()
        }
        
        // Flashing Mode
        if SCAudioManager.shared.isEditingModeEnabled || SCAudioManager.shared.isRecordingModeEnabled == true {
            cell.startCellFlashing()
        } else {
            cell.stopCellsFlashing()
        }
        // Touch delay
        if SCAudioManager.shared.isRecording == true {
            cell.isRecordingTouchDelay()
        } else {
            cell.enableTouch()
        }
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCSamplerCollectionViewCell else {
            fatalError("Wrong cell dequeued")
        }
        SCAudioManager.shared.selectedSampleIndex = indexPath.row
        
        if SCAudioManager.shared.isRecording == true {
            print("Recording in progress")
            return
        }
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            if cell.isTouchDelayed == false {
                startRecording(in: cell, samplePadIndex: indexPath.row)
            } else {
                print("extraneous cell touch was delayed.")
            }
        case false:
            if SCAudioManager.shared.isEditingModeEnabled == true {
                print("Present wave form editor for sample at pad #\(indexPath.row)")
            } else {
                if cell.isTouchDelayed == false {
                    cell.playbackSample()
                    cell.animateLayer()
                } else {
                    print("extraneous cell touch was delayed.")
                }
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
            print("IndexPath not found.")
            return
        }
        
        //now we can get the cell for item at indexPath
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            print("Cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        print("selected cell at \(indexPath.row)")
        self.collectionView(collectionView!, didSelectItemAt: indexPath)
    }
}
