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
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let triggerCV = self.triggerCV else { return }
        triggerCV.bounds.size = triggerCV.collectionViewLayout.collectionViewContentSize
        
    }
    
    
    
    
    
    
    func setupSequencer(){
        
//        while SCAudioManager.shared.sequencerSettings.count<=16 {
//            var triggers: [Bool] = []
//            while triggers.count<=16{
//                let isPlayingEnabled = false
//                triggers.append(isPlayingEnabled)
//            }
//            SCAudioManager.shared.sequencerSettings.append(triggers)
//        }
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: CGFloat(cellCount))
        triggerCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let triggerCV = self.triggerCV else { return }
        triggerCV.register(SCTriggerCell.self, forCellWithReuseIdentifier: "SCTriggerCell")
        triggerCV.delegate = self
        triggerCV.dataSource = self
        contentView.addSubview(triggerCV)
        triggerCV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint.init(item: triggerCV, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: triggerCV, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: triggerCV, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: triggerCV, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0))
    }
}


extension SCSequencerCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let result = CGSize.init(width: contentView.frame.width, height: contentView.frame.height/CGFloat(cellCount))
        return result
    }
    
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        return 4
    //    }
    
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
        cell.layer.borderWidth = 1.5
        cell.layer.borderColor = UIColor.purple.cgColor
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
            cell.backgroundColor = iceCreamColors[colorIdx]
            cell.alpha = 0.8
        } else {
            cell.padLabel.isHidden = true
            
            let seqIdx = cell.sequencerIdx
            let idx = cell.idx
            if let playbackEnabled = SCDataManager.shared.user?.currentSampleBank?.sequencerSettings?.score[seqIdx][idx] {
                cell.isPlaybackEnabled = playbackEnabled
            }
            switch cell.isPlaybackEnabled {
            case true:
                //TODO: This not DRY
                cell.backgroundColor = iceCreamColors[colorIdx]
                
            case false:
                cell.backgroundColor = UIColor.black
                
            }
        }
        
        return cell
    }
    
  
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCTriggerCell else {
            print("No cell found.")
            return
        }
        
        switch cell.isPlaybackEnabled {
        
        case true:
            cell.isPlaybackEnabled = false
            SCDataManager.shared.user?.currentSampleBank?.sequencerSettings?.score[cell.sequencerIdx][cell.idx] = false
            cell.backgroundColor = UIColor.black
        case false:
            cell.isPlaybackEnabled = true
            SCDataManager.shared.user?.currentSampleBank?.sequencerSettings?.score[cell.sequencerIdx][cell.idx] = true
            let iceCreamColors: [UIColor] = SCColor.getPsychedelicIceCreamShopColors()
            var colorIdx: Int
            colorIdx = Int(arc4random_uniform(UInt32(iceCreamColors.count)))
            cell.backgroundColor = iceCreamColors[colorIdx]
            
            if SCAudioManager.shared.sequencerIsPlaying == false {
                SCAudioManager.shared.selectedSampleIndex = cell.idx
                SCAudioManager.shared.playAudio(sampleIndex: cell.idx)
                NotificationCenter.default.post(name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)
            }
        }
    }
}



