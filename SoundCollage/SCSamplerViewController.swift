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
    var vintageColors: [UIColor] = []
    var iceCreamColors: [UIColor] = []
    let parameterViewColors: [UIColor] = [SCColor.Custom.PsychedelicIceCreamShoppe.darkViolet, SCColor.Custom.PsychedelicIceCreamShoppe.medViolet, SCColor.Custom.PsychedelicIceCreamShoppe.darkViolet]
    let backGroundColors: [UIColor] = [SCColor.Custom.PsychedelicIceCreamShoppe.deepBlue, SCColor.Custom.PsychedelicIceCreamShoppe.neonAqua, SCColor.Custom.PsychedelicIceCreamShoppe.deepBlueDark]
    var selectedPadIndex: Int?

    //MARK: vc lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SCColor.Custom.Gray.dark //SCColor.Custom.PsychedelicIceCreamShoppe.ice
        vintageColors = SCColor.getVintageColors()
        iceCreamColors = SCColor.getPsychedelicIceCreamShopColors()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.finishedRecording), name: Notification.Name.init("recordingDidFinish"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCSamplerViewController.toggleRecordingMode), name: Notification.Name.init("recordBtnDidPress"), object: nil)
        
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
        samplerCV.bounds.size = samplerCV.collectionViewLayout.collectionViewContentSize
        
        
        print("sampler size - \(samplerCV.frame.width), \(samplerCV.frame.height)")
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func calibrateSize(samplerCVWidth: CGFloat)-> Bool{
        var result: Bool = false
        
        if samplerCVWidth.truncatingRemainder(dividingBy: 4.0) == 0 && samplerCVWidth.truncatingRemainder(dividingBy: 6.0) == 0 {
            result = true
        }
        
        return result
    }
    
    
    
    
  
    
    
    private func setupSampler() {
 
        
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
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: samplerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: samplerCV, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0))
    }
    
    
        
    //MARK: recording and playback
    
    func toggleRecordingMode() {
        
        print("go on")
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            SCAudioManager.shared.isRecordingModeEnabled = false
            reloadSamplerCV()
        case false:
            SCAudioManager.shared.isRecordingModeEnabled = true 
            self.selectedPadIndex = nil
            reloadSamplerCV()
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
    
    
    func performWave(fillMode: String, row: Int, cell: SCSamplerCollectionViewCell, delays: [Double]){
        

        if row == 0 || row == 4 || row == 8 || row == 12 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[0]) {
            cell.animateColor(fillMode: fillMode)
            }
        }
        
        if row == 1 || row == 5 || row == 9 || row == 13 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[1]) {
                cell.animateColor(fillMode: fillMode)
            }
        }
        if row == 2 || row == 6 || row == 10 || row == 14 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[2]) {
                cell.animateColor(fillMode: fillMode)
            }
        }
        if row == 3 || row == 7 || row == 11 || row == 15 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[3]){
                cell.animateColor(fillMode: fillMode)
            }
        }
        cell.doWaveAnimation = false
//        cell.doXAnimation = true
    }
    
    
    func performXAnimation(fillMode: String, row: Int, cell: SCSamplerCollectionViewCell, delays: [Double]){
        
        if row == 0 || row == 5 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[0]) {
                cell.animateColor(fillMode: fillMode)
            }
        }
        
        if row == 3 || row == 6 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[1]) {
                cell.animateColor(fillMode: fillMode)
            }
        }
        if row == 10 || row == 15 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[2]) {
                cell.animateColor(fillMode: fillMode)
            }
        }
        if row == 9 || row == 12 {
            DispatchQueue.main.asyncAfter(deadline: .now()+delays[3]){
                cell.animateColor(fillMode: fillMode)
            }
        }
        cell.doXAnimation = false
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
       
        let dm = SCDataManager.shared
            
        guard let numberOfItems = dm.user?.sampleBanks?[dm.currentSampleBank!].samples?.count  else {
            print("Error, no current sample bank.")
            return 0
        }
        return numberOfItems
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSamplerCollectionViewCell", for: indexPath) as! SCSamplerCollectionViewCell
        
        // ui
        cell.idx = indexPath.row
        let colorIdx = SCColor.findColorIndex(indexPath: indexPath, colors: iceCreamColors)
        cell.cellColor = iceCreamColors[colorIdx]
        
        cell.setupLabel()
        cell.setupGradientColors()
       
        
        if indexPath.row == self.selectedPadIndex {
            cell.backgroundColor = cell.cellColor
            cell.padLabel.textColor = UIColor.white
            cell.layer.borderColor = SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet.cgColor// UIColor.black.cgColor
        } else {
            cell.backgroundColor = SCColor.Custom.Gray.dark
            cell.padLabel.textColor = UIColor.white //cell.cellColor
            cell.layer.borderColor = cell.cellColor?.cgColor

        }
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SCSamplerViewController.tap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        cell.addGestureRecognizer(tapGestureRecognizer)
        
        
        switch SCAudioManager.shared.isRecordingModeEnabled {
        case true:
            cell.isRecordingEnabled = true
            cell.startCellFlashing()
        case false:
            cell.isRecordingEnabled = false
            cell.stopCellsFlashing()
        }
        
        switch SCAudioManager.shared.isRecording {
            
        case true:
            cell.isRecordingDelayTouch()
        case false:
            cell.enableTouch()
        }

        // wave animation when navigating from samplebanks
        
        if cell.doWaveAnimation == true {
            
            performWave(fillMode: kCATransitionFromLeft, row: indexPath.row, cell: cell, delays: [0.5, 0.6, 0.7, 0.8])
        }
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCSamplerCollectionViewCell else {
            fatalError("Wrong cell or no cell at indexpath.")
        }
        SCAudioManager.shared.selectedSampleIndex = indexPath.row
   
        NotificationCenter.default.post(name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)
        
        if SCAudioManager.shared.isRecording == true {
            print("Recording in progress")
            return
        }
        
        if cell.isTouchDelayed == false {
            
            switch SCAudioManager.shared.isRecordingModeEnabled {
                
            case true:
                cell.startRecording()
                toggleRecordingMode()
                
            case false:
                cell.playbackSample()
                cell.animateColor(fillMode: kCATransitionFade)
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
        if SCAudioManager.shared.isRecordingModeEnabled == true {
            self.selectedPadIndex = indexPath.row
        }
        self.collectionView(samplerCV!, didSelectItemAt: indexPath)
    }
}





