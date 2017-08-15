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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    
    func setupSequencer(){

        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: CGFloat(cellCount))
        triggerCV = UICollectionView.init(frame: self.contentView.frame, collectionViewLayout: flowLayout)
        guard let triggerCV = self.triggerCV else { return }
        triggerCV.backgroundColor = UIColor.clear
        triggerCV.register(SCTriggerCell.self, forCellWithReuseIdentifier: "SCTriggerCell")
        triggerCV.delegate = self
        triggerCV.dataSource = self
        contentView.addSubview(triggerCV)
        
    }
}



extension SCSequencerCell: UICollectionViewDelegateFlowLayout {
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let result = CGSize.init(width: collectionView.frame.width, height: collectionView.frame.height/CGFloat(cellCount))
        return result
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
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.black.cgColor
        let iceCreamColors: [UIColor] = SCColor.getPsychedelicIceCreamShopColors()
        
        var colorIdx: Int
        if indexPath.row > iceCreamColors.count-1 {
            colorIdx = indexPath.row-iceCreamColors.count
            if colorIdx > iceCreamColors.count-1 {
                colorIdx -= iceCreamColors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        
        if self.idx == 0 {
            cell.padLabel.text = "\(cell.idx+1)"
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = SCColor.Custom.Gray.dark //UIColor.black //iceCreamColors[colorIdx]
        } else {
            cell.padLabel.isHidden = true
            
            let seqIdx = cell.sequencerIdx
            let idx = cell.idx
            
            let dm = SCDataManager.shared
            if (SCDataManager.shared.user?.sampleBanks?[dm.currentSampleBank!].sequencerSettings?.score[seqIdx][idx])! == true {
                cell.isPlaybackEnabled = true
            }
            
            
            switch cell.isPlaybackEnabled {
            case true:
                //TODO: This not DRY
                cell.backgroundColor = iceCreamColors[colorIdx]
            case false:
                cell.backgroundColor = SCColor.Custom.Gray.dark
                //                cell.addGlow(color: iceCreamColors[colorIdx])
                
            }
        }
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SCSequencerCell.tap(gestureRecognizer:)))
        tapGestureRecognizer.delegate = self
        cell.addGestureRecognizer(tapGestureRecognizer)
        

        
        return cell
    }
    
  
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCTriggerCell else {
            print("No cell found.")
            return
        }
        
        guard let currentSB = SCDataManager.shared.user?.sampleBanks?[SCDataManager.shared.currentSampleBank!]  else {
            print("Error, no current sample bank.")
            return
        }
        
        switch cell.isPlaybackEnabled {
        
        case true:
            cell.isPlaybackEnabled = false
            currentSB.sequencerSettings?.score[cell.sequencerIdx][cell.idx] = false
            cell.backgroundColor = SCColor.Custom.Gray.dark
        case false:
            cell.isPlaybackEnabled = true
            currentSB.sequencerSettings?.score[cell.sequencerIdx][cell.idx] = true
            let iceCreamColors: [UIColor] = SCColor.getPsychedelicIceCreamShopColors()
            var colorIdx: Int
            colorIdx = Int(arc4random_uniform(UInt32(iceCreamColors.count)))
            cell.backgroundColor = iceCreamColors[colorIdx]
            
            if SCAudioManager.shared.sequencerIsPlaying == false {
                SCAudioManager.shared.selectedSequencerIndex = cell.idx
    
                NotificationCenter.default.post(name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)
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




extension SCSequencerCell: UIGestureRecognizerDelegate {
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    
    func tap(gestureRecognizer: UIGestureRecognizer) {
        
        if SCAudioManager.shared.isRecording == true {
            print("Recording in progress")
            return
        }
        
        
        let tapLocation = gestureRecognizer.location(in: self.triggerCV)
        
        guard let indexPath = self.triggerCV?.indexPathForItem(at: tapLocation) else {
            print("IndexPath not found.")
            return
        }
        
        guard let cell = self.triggerCV?.cellForItem(at: indexPath) else {
            print("Cell not found.")
            return
        }
        
        selectCell(cell: cell, indexPath: indexPath)
    }
    
    
    
    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        
        print("selected cell at \(indexPath.row)")
      
        self.collectionView(triggerCV!, didSelectItemAt: indexPath)
    }
}




