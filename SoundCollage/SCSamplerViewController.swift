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
    
    var samplerCV: UICollectionView?
    var effectsContainerCV: UICollectionView?
    let recordBtn = UIButton()
    var speakerBtn = UIButton()
    var newRecordingTitle: String?
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    let navBarBtnFrameSize = CGRect.init(x: 0, y: 0, width: 30, height: 30)
    let toolbarHeight = CGFloat(49.0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordingDidFinishNotification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.finishedRecording), name: recordingDidFinishNotification, object: nil)
        setupControls()
        setupContainerViews()
        animateEntrance()
        
    }
    
    //MARK: Setup UI
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let samplerCV = self.samplerCV else {
            print("collectionview is nil")
            return
        }
        samplerCV.bounds.size = samplerCV.collectionViewLayout.collectionViewContentSize
        
        guard let effectsCCV = self.effectsContainerCV else {
            print("No effectsCCV.")
            return
        }
        effectsCCV.bounds.size = effectsCCV.collectionViewLayout.collectionViewContentSize
    }
    
    
    
    
    private func setupContainerViews() {
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 3)
        self.samplerCV = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        guard let samplerCV = self.samplerCV else {
            print("No sampler collection view.")
            return
        }
        
        samplerCV.backgroundColor = UIColor.clear
        samplerCV.allowsMultipleSelection = true
        samplerCV.isScrollEnabled = false
        samplerCV.register(SCSamplerCollectionViewCell.self, forCellWithReuseIdentifier: "SCSamplerCollectionViewCell")
        samplerCV.delegate = self
        samplerCV.dataSource = self
        
        self.view.addSubview(samplerCV)
        
        samplerCV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -30.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 60.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.57, constant: 0))
        
        
        
        let effectsFlowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 3)
        self.effectsContainerCV = UICollectionView.init(frame: .zero, collectionViewLayout: effectsFlowLayout)
        guard let effectsContainerCV = self.effectsContainerCV else {
            print("No effects container.")
            return
        }
        effectsContainerCV.allowsMultipleSelection = false
        effectsContainerCV.delegate = self
        effectsContainerCV.dataSource = self
        effectsContainerCV.register(SCEffectPickerCell.self, forCellWithReuseIdentifier: "SCEffectPickerCell")
        effectsContainerCV.register(SCEffectParameterCell.self, forCellWithReuseIdentifier: "SCEffectParameterCell")
        effectsContainerCV.register(SCSequencerControlCell.self, forCellWithReuseIdentifier:  "SCSequencerControlCell")
        
        effectsContainerCV.backgroundColor = UIColor.clear
        self.view.addSubview(effectsContainerCV)
        
        effectsContainerCV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 30.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -30.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .top, relatedBy: .equal, toItem: samplerCV, attribute: .bottom, multiplier: 1.0, constant: 40.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.17, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .width, multiplier: 1.0, constant: -60))
        print("width of effects\(effectsContainerCV.frame.width)")
    }
    
    
    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.height - toolbarHeight, width: self.view.bounds.size.width, height: toolbarHeight))
        toolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        
        let buttonHeight = toolbarHeight/2
        let yPosition = view.frame.height-20-buttonHeight
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
        
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
       

        
        let navBar = UINavigationBar.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50 ))
        navBar.setBackgroundImage(transparentPixel, for: .default)
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
        
        navItem.rightBarButtonItems = [speakerBarBtn]
        navBar.items = [navItem]

        toolbar.items = [flexibleSpace, recordBarBtn, flexibleSpace, editorBarBtn]
        self.view.addSubview(toolbar)
        
        
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
            reloadSamplerCV()
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
    
    
    
    func reloadSamplerCV() {
        guard let cv = self.samplerCV else {
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
        reloadSamplerCV()
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
        reloadSamplerCV()
    }
}




extension SCSamplerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == samplerCV {
            return 12
        } else {
            return 3
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == samplerCV {
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
        } else  {
            switch indexPath.row {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCEffectPickerCell", for: indexPath) as! SCEffectPickerCell
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCEffectParameterCell", for: indexPath) as! SCEffectParameterCell
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSequencerControlCell", for: indexPath) as! SCSequencerControlCell
                return cell
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == samplerCV {
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? SCSamplerCollectionViewCell else {
                fatalError("Wrong cell or no cell at indexpath.")
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
        } else {
            switch indexPath.row {
            case 0:
                print("Effects picker tapped.")
            case 1:
                print("Effects parameter tapped.")
            default:
                print("Sequencer control tapped.")
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if collectionView == samplerCV {
            if let selectedItems = collectionView.indexPathsForSelectedItems {
                if selectedItems.contains(indexPath) {
                    collectionView.deselectItem(at: indexPath, animated: true)
                    return false
                }
            }
            return true
        }
        return true // default
    }
}




extension SCSamplerViewController: UIGestureRecognizerDelegate {
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    func tap(gestureRecognizer: UITapGestureRecognizer) {
        let tapLocation = gestureRecognizer.location(in: self.samplerCV)
        
        guard let indexPath = self.samplerCV?.indexPathForItem(at: tapLocation) else {
            print("IndexPath not found.")
            return
        }
        
        //now we can get the cell for item at indexPath
        guard let cell = self.samplerCV?.cellForItem(at: indexPath) else {
            print("Cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        print("selected cell at \(indexPath.row)")
        self.collectionView(samplerCV!, didSelectItemAt: indexPath)
    }
}
