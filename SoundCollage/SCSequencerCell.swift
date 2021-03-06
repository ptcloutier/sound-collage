//
//  SCSequencerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSequencerCell: UICollectionViewCell {
    
    var triggerCV: UICollectionView?
    var idx: Int = 0
    let cellCount: Int = 16
    var iceCreamColors: [UIColor] = []
    var seaColors: [UIColor] = []
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    
    func setupSequencer(){
        
        iceCreamColors = SCColor.getPsychedelicIceCreamShopColors()
        seaColors = SCColor.getVintageColors()
        
        contentView.backgroundColor = UIColor.clear
        print("seq cell\(self.contentView.frame.height)")
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: CGFloat(cellCount))
        triggerCV = UICollectionView.init(frame: self.contentView.frame, collectionViewLayout: flowLayout)
        guard let triggerCV = self.triggerCV else { return }
        triggerCV.isScrollEnabled = false 
        triggerCV.backgroundColor = UIColor.clear
        triggerCV.allowsMultipleSelection = true
        triggerCV.register(SCTriggerCell.self, forCellWithReuseIdentifier: "SCTriggerCell")
        triggerCV.delegate = self
        triggerCV.dataSource = self
        contentView.addSubview(triggerCV)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(SCSequencerCell.touch(gestureRecognizer:)))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        triggerCV.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(SCSequencerCell.touch(gestureRecognizer:)))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        triggerCV.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer.init(target: self, action: #selector(SCSequencerCell.touch(gestureRecognizer:)))
        swipe.delegate = self
        swipe.cancelsTouchesInView = false 
        triggerCV.addGestureRecognizer(swipe)
    }
}








extension SCSequencerCell:  UICollectionViewDelegate, UICollectionViewDataSource {
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    
    func reloadCV(){
        self.triggerCV?.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = triggerCV?.dequeueReusableCell(withReuseIdentifier: "SCTriggerCell", for: indexPath) as!SCTriggerCell
        
        cell.sequencerIdx = self.idx-1
        cell.idx = indexPath.row
       
        // get bright colors
//        let colors = SCColor.getPsychedelicIceCreamShopColors()
//        let iccolors = SCColor.getPsychedelicIceCreamShopColors()
//        var brightColors: [UIColor] = []
//       
//        for color in colors {
//            let bright = SCColor.BrighterHigherSatColor(color: color)
//            brightColors.append(bright)
//        }
//        
//        for ic in iccolors {
//            let brighterIC = SCColor.BrighterHigherSatColor(color: ic)
//            brightColors.append(brighterIC)
//        }

        
        var colorIdx: Int
        if indexPath.row > iceCreamColors.count-1 {
            colorIdx = indexPath.row-iceCreamColors.count
            if colorIdx > iceCreamColors.count-1 {
                colorIdx -= iceCreamColors.count
            }
        } else {
            colorIdx = indexPath.row
        }
       

        if self.idx == 0 { // first row 
            cell.circularCell()
            cell.padLabel.text = "\(cell.idx+1)"
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = SCColor.Custom.Gray.dark
        } else {
            cell.padLabel.isHidden = true
            let seqIdx = cell.sequencerIdx
            let idx = cell.idx
            cell.layer.borderWidth = 0.75
            cell.layer.borderColor = seaColors[colorIdx].cgColor
            let dm = SCDataManager.shared
            if (SCDataManager.shared.user?.sampleBanks[dm.currentSampleBank!].sequencerSettings?.score[seqIdx][idx])! == true {
                cell.isPlaybackEnabled = true
            }
            
            switch cell.isPlaybackEnabled {
            case true:
                cell.backgroundColor = iceCreamColors[colorIdx]
            case false:
                cell.backgroundColor = SCColor.Custom.Gray.dark
            }
        }
        return cell
    }
    
  
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCTriggerCell else {
            print("No cell found.")
            return
        }
        
        guard let currentSB = SCDataManager.shared.user?.sampleBanks[SCDataManager.shared.currentSampleBank!]  else {
            print("Error, no current sample bank.")
            return
        }
        
        var colorIdx: Int
        if indexPath.row > iceCreamColors.count-1 {
            colorIdx = indexPath.row-iceCreamColors.count
            if colorIdx > iceCreamColors.count-1 {
                colorIdx -= iceCreamColors.count
            }
        } else {
            colorIdx = indexPath.row
        }

        
        switch cell.isPlaybackEnabled { // toggle
        
        case true:
            cell.isPlaybackEnabled = false
            currentSB.sequencerSettings?.score[cell.sequencerIdx][cell.idx] = false
//            var colorIdx: Int
//            colorIdx = indexPath.row
            cell.backgroundColor = SCColor.Custom.Gray.dark //iceCreamColors[colorIdx]
        case false:
            cell.isPlaybackEnabled = true
            currentSB.sequencerSettings?.score[cell.sequencerIdx][cell.idx] = true
            cell.backgroundColor =  iceCreamColors[colorIdx]
            if SCAudioManager.shared.sequencerIsPlaying == false {
                SCAudioManager.shared.selectedSequencerIndex = cell.idx
    
                NotificationCenter.default.post(name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)
            }
        }
    }
    
//    
//    
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        
//        if let selectedItems = collectionView.indexPathsForSelectedItems {
//            if selectedItems.contains(indexPath) {
//                collectionView.deselectItem(at: indexPath, animated: true)
//                return false
//            }
//        }
//        return true
//    }
}



extension SCSequencerCell: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let result = CGSize.init(width: collectionView.frame.width, height: collectionView.frame.width)
        return result
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let h = contentView.frame.height - 69.0 //toolbar+top spacing
        let spacing = h/40// TODO: calculate, don't use hardcoded values
        
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}



extension SCSequencerCell: UIGestureRecognizerDelegate {
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    @objc func touch(gestureRecognizer: UIGestureRecognizer) {
        
        if SCAudioManager.shared.isRecordingOutput == true {
            print("Recording in progress")
            return
        }
        
        let touchLocation = gestureRecognizer.location(in: self.triggerCV)
        
        guard let indexPath = self.triggerCV?.indexPathForItem(at: touchLocation) else {
            print("IndexPath not found.")
            return
        }
        
        guard let cell = self.triggerCV?.cellForItem(at: indexPath) as? SCTriggerCell else {
            print("Cell not found.")
            return
        }
        if cell.sequencerIdx == -1 {
            print("seq idx -1, deselect")
            return
        }
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        print("selected seq cell at \(indexPath.row)")
        
        self.collectionView(triggerCV!, didSelectItemAt: indexPath)
    }
}



