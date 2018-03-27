//
//  SamplerViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import SpriteKit

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
     // Sprite
    var scene: PCScene!
    var size: CGSize!
    var flashTimer: Timer? = nil
    var touchLocation = CGPoint()
    var shapeIdx: Int = 0
    var shapeLocations: [CGPoint] = []
    var shapeMaxLocations: [CGPoint] = []
    var shapeMinLocations: [CGPoint] = []
    
    
 
    override func loadView() {
        self.view = SKView()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        SCAudioManager.shared.getAudioFilesForURL()
        let colors = SCColor.getPsychedelicIceCreamShopColors()
        var brightColors: [UIColor] = []
        for color in colors {
            let bright = SCColor.BrighterHigherSatColor(color: color)
            brightColors.append(bright)
        }

        iceCreamColors = brightColors//SCColor.getPsychedelicIceCreamShopColors()

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

        samplerCV.backgroundColor = UIColor.black
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SCSamplerViewController.tap(gestureRecognizer:)))
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    
    //MARK: recording and playback
    
    @objc func toggleRecordingMode() {
        
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
    
    
    
    @objc func finishedRecording() {
        reloadSamplerCV()
        print("Recording finished.")
    }
    
    
    func findPointInCell() -> Int {

        let shapeX = touchLocation.x
        let shapeY = touchLocation.y

        for (idx, shapeLoc) in shapeLocations.enumerated() {
            print("idx = \(idx), shape loc - \(shapeLoc.x), \(shapeLoc.y)")

            let minX = shapeMinLocations[idx].x
            let maxX = shapeMaxLocations[idx].x
            let minY = shapeMinLocations[idx].y
            let maxY = shapeMaxLocations[idx].y
            if shapeX >= minX && shapeX <= maxX {
                print("shape x test passed")
                if shapeY >= minY && shapeY <= maxY {
                    print("shape y test passed")
                    print("shape idx = \(idx)")
                    return idx
                }
            }
        }
        return 0
    }
}




extension SCSamplerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        let dm = SCDataManager.shared
            
        guard let numberOfItems = dm.user?.sampleBanks[dm.currentSampleBank!].samples.count  else {
            print("Error, no current sample bank.")
            return 0
        }
        return numberOfItems
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSamplerCollectionViewCell", for: indexPath) as! SCSamplerCollectionViewCell
        cell.idx = indexPath.row
        var colorIdx: Int
        if indexPath.row > iceCreamColors.count-1 {
            colorIdx = indexPath.row-iceCreamColors.count
            if colorIdx > iceCreamColors.count-1 {
                colorIdx -= iceCreamColors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        cell.cellColor = iceCreamColors[colorIdx]
        cell.setupLabel()
        cell.setupGradientColors()
        cell.circularCell()
        cell.layer.borderWidth = 5.0
        cell.layer.borderColor = cell.cellColor?.cgColor
        cell.padLabel.textColor = UIColor.white
        
        if indexPath.row == self.selectedPadIndex {
            cell.cellColor = iceCreamColors[colorIdx]
        }
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
        // get the cell locations and store in an array
        if shapeLocations.count < 16 {
            shapeLocations.append(cell.center)
            let minX = cell.frame.minX
            let minY = cell.frame.minY
            let minPoint = CGPoint(x: minX, y: minY)
            let maxX = cell.frame.maxX
            let maxY = cell.frame.maxY
            let maxPoint = CGPoint(x: maxX, y: maxY)
            shapeMinLocations.append(minPoint)
            shapeMaxLocations.append(maxPoint)
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
    
    @objc func pan(gestureRecognizer: UIPanGestureRecognizer){
        handleGestureRecognizer(gestureRecognizer: gestureRecognizer)
    }
    
    @objc func tap(gestureRecognizer: UITapGestureRecognizer) {
        handleGestureRecognizer(gestureRecognizer: gestureRecognizer)
    }
    
    
    
    func handleGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        if SCAudioManager.shared.isRecording == true {
            print("Recording in progress")
            return
        }
        
        let touchLocation = gestureRecognizer.location(in: view)
        // set location to drop a skshapenode at touch location
        self.touchLocation = touchLocation
        print("touch location - \(touchLocation.x) \(touchLocation.y)")
        

        guard let indexPath = self.samplerCV?.indexPathForItem(at: touchLocation) else {
            print("IndexPath not found.")
            return
        }
        self.shapeIdx = indexPath.row
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





extension SCSamplerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = CGSize.init(width: (samplerFlowLayout?.itemSize.width)!, height: (samplerFlowLayout?.itemSize.height)!)
        return itemSize
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




