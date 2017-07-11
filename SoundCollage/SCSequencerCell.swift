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
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 16)
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
        let result = CGSize.init(width: contentView.frame.width, height: contentView.frame.height/16)
        return result
    }
    
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        return 4
    //    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = triggerCV?.dequeueReusableCell(withReuseIdentifier: "SCTriggerCell", for: indexPath) as!SCTriggerCell
        cell.sequencerIdx = self.idx
        cell.idx = indexPath.row
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.purple.cgColor
        print("cell idx: \(cell.idx), sequencer idx: \(cell.sequencerIdx)")

        
        switch cell.isPlaybackEnabled {
        case true:
            //TODO: This not DRY
            let iceCreamColors: [UIColor] = SCGradientColors.getPsychedelicIceCreamShopColors()
            
            var colorIdx: Int
            if indexPath.row > iceCreamColors.count-1 {
                colorIdx = indexPath.row-iceCreamColors.count
                if colorIdx > iceCreamColors.count-1 {
                    colorIdx -= iceCreamColors.count
                }
            } else {
                colorIdx = indexPath.row
            }
            cell.backgroundColor = iceCreamColors[colorIdx]
            
            
        case false:
            cell.backgroundColor = UIColor.clear
            
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
            cell.backgroundColor = UIColor.clear
            
        case false:
            
            cell.isPlaybackEnabled = true
            
            //TODO: This not DRY
            let iceCreamColors: [UIColor] = SCGradientColors.getPsychedelicIceCreamShopColors()
            
            var colorIdx: Int
            if indexPath.row > iceCreamColors.count-1 {
                colorIdx = indexPath.row-iceCreamColors.count
                if colorIdx > iceCreamColors.count-1 {
                    colorIdx -= iceCreamColors.count
                }
            } else {
                colorIdx = indexPath.row
            }
            cell.backgroundColor = iceCreamColors[colorIdx]
        }
    }
}



