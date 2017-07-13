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
    
    var recordBtn: UIButton?
    var parameterView: UIView?
    var samplerCV: UICollectionView?
    var samplerFlowLayout: SCSamplerFlowLayout?
    var effectsContainerCV: UICollectionView?
    var newRecordingTitle: String?
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    let navBarBtnFrameSize = CGRect.init(x: 0, y: 0, width: 30, height: 30)
    let toolbarHeight = CGFloat(98.0)
    var toolbar = UIToolbar()
    var effects: [String] = []
    var vintageColors: [UIColor] = []
    var iceCreamColors: [UIColor] = []
    let parameterViewColors: [UIColor] = [UIColor.Custom.PsychedelicIceCreamShoppe.darkViolet, UIColor.Custom.PsychedelicIceCreamShoppe.medViolet, UIColor.Custom.PsychedelicIceCreamShoppe.darkViolet]
    let backGroundColors: [UIColor] = [UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, UIColor.Custom.PsychedelicIceCreamShoppe.neonAqua, UIColor.Custom.PsychedelicIceCreamShoppe.deepBlueDark]
    
    
    //MARK: vc lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        effects = ["reverb", "delay", "pitch"]

        view.backgroundColor = UIColor.clear //UIColor.Custom.PsychedelicIceCreamShoppe.ice
        vintageColors = SCGradientColors.getVintageColors()
        iceCreamColors = SCGradientColors.getPsychedelicIceCreamShopColors()
       
        
        let recordingDidFinishNotification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.finishedRecording), name: recordingDidFinishNotification, object: nil)
        setupControls()
        setupContainerViews()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let samplerCV = self.samplerCV else {
            print("collectionview is nil")
            return
        }
        while calibrateSize(samplerCVWidth: samplerCV.frame.size.width) == false {
            samplerCV.frame.size.width = samplerCV.frame.size.width-1.0
        }
        if SCDataManager.shared.user?.currentSampleBank?.type == SCSampleBank.SamplerType.standard {
            samplerCV.bounds.size = samplerCV.collectionViewLayout.collectionViewContentSize
        }
    }
    
    
    

    
    func calibrateSize(samplerCVWidth: CGFloat)-> Bool{
        var result: Bool = false
        
        if samplerCVWidth.truncatingRemainder(dividingBy: 4.0) == 0 && samplerCVWidth.truncatingRemainder(dividingBy: 6.0) == 0 {
          result = true
        }

        return result
    }
    
    
    
    
    //MARK: Collection views
    
    
    private func setupContainerViews() {
        
        // main sampler
        
        var numberOfColumns: CGFloat
        
        if SCDataManager.shared.user?.currentSampleBank?.type == SCSampleBank.SamplerType.double {
            numberOfColumns = 6
        } else {
            numberOfColumns = 4
        }
        samplerFlowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: numberOfColumns)
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
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .height, multiplier: 0.57, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0))
        
        // effects
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
        parameterView.backgroundColor = UIColor.clear
        
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
    
    
    
    
    //MARK: ui setup

    
    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = toolbar.center.y-buttonHeight/2
        
        self.recordBtn = UIButton.GradientColorStyle(height: buttonHeight, gradientColors: [UIColor.red, UIColor.magenta, UIColor.orange], secondaryColor: UIColor.white)
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        recordBtn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let bankBtn = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral, secondaryColor: UIColor.white)
        bankBtn.addTarget(self, action: #selector(SCSamplerViewController.bankBtnDidPress), for: .touchUpInside)
        
        
        let sequencerBtn = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.lightBlueSky, secondaryColor: UIColor.white)
        sequencerBtn.addTarget(self, action: #selector(SCSamplerViewController.presentSequencer), for: .touchUpInside)
        
        let tempBtn2 = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.rose, secondaryColor: UIColor.white)
        
        let tempBtn3 = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, secondaryColor: UIColor.white)
        
        let bankBarBtn = UIBarButtonItem.init(customView: bankBtn)
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        let sequencerBarBtn = UIBarButtonItem.init(customView: sequencerBtn)
        let tempBarBtn2 = UIBarButtonItem.init(customView: tempBtn2)
        let tempBarBtn3 = UIBarButtonItem.init(customView: tempBtn3)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    

        toolbar.items = [flexibleSpace, bankBarBtn, flexibleSpace, sequencerBarBtn, flexibleSpace,  recordBarBtn, flexibleSpace, tempBarBtn2, flexibleSpace, tempBarBtn3, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    
    
    func findColorIndex(indexPath: IndexPath, colors: [UIColor])-> Int{
        
        var colorIdx: Int
        if indexPath.row > colors.count-1 {
            colorIdx = indexPath.row-colors.count
            if colorIdx > colors.count-1 {
                colorIdx -= colors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        return colorIdx
    }
    
    
    
    //MARK: Navigation
    
    
    func bankBtnDidPress(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    func presentSequencer(){
        
        let vc: SCScoreViewController = SCScoreViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    //MARK: recording and playback
    
    
    
    
    func recordBtnDidPress(){
        
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        switch SCAudioManager.shared.isRecording {
        case true:
            SCAudioManager.shared.finishRecording(success: true)
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        case false:
            toggleRecordingMode()
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
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
    
    
    
    func finishedRecording() {
        reloadSamplerCV()
        print("Recording finished.")
    }
    
    
    
    func toggleRecordingMode() {
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            SCAudioManager.shared.isRecordingModeEnabled = false
            print("Recording mode not enabled.")
        case false:
            SCAudioManager.shared.isRecordingModeEnabled = true
            print("Recording mode enabled.")
        }
        reloadSamplerCV()
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
    
    
    
    
    //MARK: effects parameter
    
    func handleParameterGesture(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            let location =  gestureRecognizer.location(in: parameterView)
            
            let sampleIndex = SCAudioManager.shared.selectedSampleIndex
            SCAudioManager.shared.handleEffectsParameters(point: location, sampleIndex: sampleIndex)
        }
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
            guard let numberOfItems = SCDataManager.shared.user?.currentSampleBank?.samples.count else {
                print("No samples found.")
                return 0
            }
            return numberOfItems
        } else {
            print("\(effects.count)")
            return effects.count

        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == samplerCV {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSamplerCollectionViewCell", for: indexPath) as! SCSamplerCollectionViewCell
            
            // ui
            cell.idx = indexPath.row
            let colorIdx = findColorIndex(indexPath: indexPath, colors: iceCreamColors)
            cell.cellColor = iceCreamColors[colorIdx]
            cell.layer.borderColor = cell.cellColor?.cgColor
            cell.layer.borderWidth = 3.0
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 10.0
            cell.setupLabel()
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SCSamplerViewController.tap(gestureRecognizer:)))
            tapGestureRecognizer.delegate = self
            cell.addGestureRecognizer(tapGestureRecognizer)
            
            
            switch SCAudioManager.shared.isRecordingModeEnabled {
            case true:
                cell.isRecordingEnabled = true
                cell.startCellFlashing()
            case false:
                cell.isRecordingEnabled = false
                cell.stopCellsFlashing()
            }
//            
//            if SCAudioManager.shared.isRecording == true && SCAudioManager.shared.selectedSampleIndex == self.idx {
//                self.layer.borderColor = UIColor.white.cgColor
//                self.padLabel.textColor = UIColor.white
//                self.backgroundColor = cellColor
//            } else {
//                self.layer.borderColor = cellColor?.cgColor
//                self.padLabel.textColor = cellColor
//                self.backgroundColor = UIColor.white

            switch SCAudioManager.shared.isRecording {
                
            case true:
                cell.isRecordingDelayTouch()
//                if indexPath.row == SCAudioManager.shared.selectedSampleIndex {
//                    cell.backgroundColor = cell.cellColor
//                    cell.layer.borderColor = UIColor.black.cgColor
//                    cell.padLabel.textColor = UIColor.black
//                }
            case false:
                cell.enableTouch()
            }
            
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as! SCEffectCell
            cell.colors = SCGradientColors.getPsychedelicIceCreamShopColors()
            cell.effect = effects[indexPath.row]
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 10.0
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
                    cell.showIndicator()
                    toggleRecordingMode()
                    cell.backgroundColor = cell.cellColor
                    cell.padLabel.textColor = UIColor.clear
                }
            case false:
                if cell.isTouchDelayed == false {
                    cell.playbackSample()
                    cell.animateCell()
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
        
        if SCAudioManager.shared.isRecording == true {
            print("Recording in progress")
            return
        }
        
        
        let tapLocation = gestureRecognizer.location(in: self.samplerCV)
        
        guard let indexPath = self.samplerCV?.indexPathForItem(at: tapLocation) else {
            print("IndexPath not found.")
            return
        }
        
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
