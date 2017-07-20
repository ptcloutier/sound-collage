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
    var samplerFlowLayout: SCSamplerFlowLayout?
    var newRecordingTitle: String?
    var lastRecording: URL?
    var selectedSampleIndex: Int?
    var vintageColors: [UIColor] = []
    var iceCreamColors: [UIColor] = []
    let parameterViewColors: [UIColor] = [UIColor.Custom.PsychedelicIceCreamShoppe.darkViolet, UIColor.Custom.PsychedelicIceCreamShoppe.medViolet, UIColor.Custom.PsychedelicIceCreamShoppe.darkViolet]
    let backGroundColors: [UIColor] = [UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, UIColor.Custom.PsychedelicIceCreamShoppe.neonAqua, UIColor.Custom.PsychedelicIceCreamShoppe.deepBlueDark]
    
    
    
    
    //MARK: vc lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear //UIColor.Custom.PsychedelicIceCreamShoppe.ice
        vintageColors = SCGradientColors.getVintageColors()
        iceCreamColors = SCGradientColors.getPsychedelicIceCreamShopColors()
        
        
        let recordingDidFinishNotification = Notification.Name.init("recordingDidFinish")
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.finishedRecording), name: recordingDidFinishNotification, object: nil)
        setupSampler()
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
    
    
    
    
  
    
    
    private func setupSampler() {
 
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
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: samplerCV, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
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
}




extension SCSamplerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let itemSize = samplerFlowLayout?.itemSize else {
            print("No sampler flowLayout.")
            return collectionView.frame.size
        }
        return itemSize
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItems = SCDataManager.shared.user?.currentSampleBank?.samples.count else {
            print("No samples found.")
            return 0
        }
        return numberOfItems
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
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



extension SCSamplerViewController: SCRecordBtnDelegate {
    
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
}


