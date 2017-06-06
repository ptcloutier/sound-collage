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
    
    var parameterView: UIView?
    var samplerCV: UICollectionView?
    var samplerFlowLayout: SCSamplerFlowLayout?
    var effectsContainerCV: UICollectionView?
    let recordBtn = UIButton()
    var newRecordingTitle: String?
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    let navBarBtnFrameSize = CGRect.init(x: 0, y: 0, width: 30, height: 30)
    let toolbarHeight = CGFloat(98.0)
    var effects: [String] = []
    var toolbar = UIToolbar()
    var vintageColors: [UIColor] = []
    var iceCreamColors: [UIColor] = []
    let parameterViewColors: [UIColor] = [UIColor.Custom.PsychedelicIceCreamShoppe.darkViolet, UIColor.Custom.PsychedelicIceCreamShoppe.medViolet, UIColor.Custom.PsychedelicIceCreamShoppe.darkViolet]
    let backGroundColors: [UIColor] = [UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, UIColor.Custom.PsychedelicIceCreamShoppe.neonAqua, UIColor.Custom.PsychedelicIceCreamShoppe.deepBlueDark]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        effects = ["reverb", "delay", "pitch"]

        vintageColors = SCGradientColors.getVintageColors()
        iceCreamColors = SCGradientColors.getPsychedelicIceCreamShopColors()
//        self.view.applyGradient(withColors: backGroundColors, gradientOrientation: .horizontal)
        let recordingDidFinishNotification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.finishedRecording), name: recordingDidFinishNotification, object: nil)
        setupControls()
        setupContainerViews()
        animateEntrance()
        
    }
    
    //MARK: Setup UI
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        guard let parameterView = self.parameterView else {
//            print("No parameter view.")
//            return
//        }
//        parameterView.applyGradient(withColors: parameterViewColors, gradientOrientation: .horizontal)
        
        guard let samplerCV = self.samplerCV else {
            print("collectionview is nil")
            return
        }
        samplerCV.bounds.size = samplerCV.collectionViewLayout.collectionViewContentSize

    }
    
    
    //MARK: Collection views
    
    
    private func setupContainerViews() {
        
        samplerFlowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 4)
        guard let samplerFlowLayout = self.samplerFlowLayout else {
            print("No sampler flow layout.")
            return
        }
        self.samplerCV = UICollectionView(frame: .zero, collectionViewLayout: samplerFlowLayout)
        
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
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.57, constant: 0))
        
        
        
        let effectsFlowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 1)
        self.effectsContainerCV = UICollectionView.init(frame: .zero, collectionViewLayout: effectsFlowLayout)
        guard let effectsContainerCV = self.effectsContainerCV else {
            print("No effects container.")
            return
        }
        effectsContainerCV.isPagingEnabled = true
        effectsContainerCV.allowsMultipleSelection = true
        effectsContainerCV.delegate = self
        effectsContainerCV.dataSource = self
        effectsContainerCV.isScrollEnabled = true
        effectsContainerCV.register(SCEffectCell.self, forCellWithReuseIdentifier: "EffectCell")
        effectsContainerCV.backgroundColor = UIColor.clear
        self.view.addSubview(effectsContainerCV)
        
        effectsContainerCV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.20, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .top, relatedBy: .equal, toItem: samplerCV, attribute: .bottom, multiplier: 1.0, constant: 20))
        self.view.addConstraint(NSLayoutConstraint.init(item: effectsContainerCV, attribute: .height, relatedBy: .equal, toItem: toolbar, attribute: .height, multiplier: 2, constant: 0))
        
        parameterView = UIView.init(frame: .zero)
        guard let parameterView = self.parameterView else {
            print("No parameter view.")
            return
        }
        
        parameterView.isUserInteractionEnabled = true
        parameterView.isMultipleTouchEnabled = false
        parameterView.layer.masksToBounds = true
        parameterView.layer.cornerRadius = 15.0
        parameterView.layer.borderWidth = 3
        parameterView.layer.borderColor = UIColor.purple.cgColor
        parameterView.backgroundColor = UIColor.Custom.PsychedelicIceCreamShoppe.ice
        
        
        self.view.addSubview(parameterView)
        parameterView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .leading, relatedBy: .equal, toItem: effectsContainerCV, attribute: .trailing, multiplier: 1.0, constant: 5.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -self.view.frame.width/5-5))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .top, relatedBy: .equal, toItem: samplerCV, attribute: .bottom, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .top, multiplier: 1.0, constant: 0))
        
        

        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(handleParameterGesture))
        parameterView.addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(handleParameterGesture))
        parameterView.addGestureRecognizer(tap)
    }
    
    
    
    
    //MARK: Effects Parameter
    
    func handleParameterGesture(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            let location =  gestureRecognizer.location(in: parameterView)
            
            guard let sampleIndex = SCAudioManager.shared.selectedSampleIndex else {
                print("No selected sample index.")
                return
            }
            SCAudioManager.shared.handleEffectsParameters(point: location, sampleIndex: sampleIndex)
        }
    }
    
    
    
    
    
    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = toolbar.center.y-buttonHeight/2
        recordBtn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        
        let backgroundView = UIView.init(frame: recordBtn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.applyGradient(withColors: [UIColor.red, UIColor.magenta, UIColor.orange], gradientOrientation: .topLeftBottomRight)
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.borderWidth = 3.0
        backgroundView.layer.borderColor = UIColor.purple.cgColor
        recordBtn.addSubview(backgroundView)
        recordBtn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    

        toolbar.items = [flexibleSpace, recordBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
        
        
    }
    
    
    //MARK: Animations
    
    
    
    private func animateEntrance() {
    
        view.alpha = 0
        UIView.animate(withDuration: 1.0, delay: 1.5, options: [.curveEaseInOut], animations:{
            self.view.alpha = 1
            }, completion: nil)
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
  
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == samplerCV {
            guard let itemSize = samplerFlowLayout?.itemSize else {
                print("No sampler flowLayout.")
                return collectionView.frame.size
            }
            return itemSize
        } else {
            let effectsCellSize = CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height/5)
            return effectsCellSize
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == samplerCV {
            return 16
        } else {
            print("\(effects.count)")
            return effects.count

        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == samplerCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSamplerCollectionViewCell", for: indexPath) as! SCSamplerCollectionViewCell
            
            cell.cellColor = iceCreamColors[indexPath.row]
            cell.setRecordingColorSets()
            cell.setupGradientLayer()
//            cell.layer.masksToBounds = true
//            cell.layer.cornerRadius = 15.0
            // border
            cell.layer.borderColor = UIColor.purple.cgColor
            cell.layer.borderWidth = 3.0
//            cell.layer.cornerRadius = 15.0
            //shadow
//            cell.layer.shadowColor = UIColor.darkGray.cgColor
//            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
//            cell.layer.shadowOpacity = 0.7
//            cell.layer.shadowRadius = 3.0
            
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
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as! SCEffectCell
            cell.colors = SCGradientColors.getPsychedelicIceCreamShopColors()
            cell.effect = effects[indexPath.row]
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 10.0
            // border
            cell.layer.borderColor = UIColor.purple.cgColor
            cell.layer.borderWidth = 3.0
            cell.layer.cornerRadius = 10.0
            //shadow
            cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowOffset = CGSize(width: 3, height: 3)
            cell.layer.shadowOpacity = 0.7
            cell.layer.shadowRadius = 3.0

            cell.contentView.backgroundColor = iceCreamColors[indexPath.row]
            cell.setupLabel()
            return cell 
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
            guard let cell = collectionView.cellForItem(at: indexPath) as? SCEffectCell else {
                print("Wrong cell or no cell at indexPath.")
                return
            }
            cell.toggleEffectIsSelected(index: indexPath.row)
            collectionView.deselectItem(at: indexPath, animated: true)
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
