//
//  SCScoreCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCScoreCell: UICollectionViewCell {

    var sequencerCV: UICollectionView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let sequencerCV = self.sequencerCV else { return }
        sequencerCV.bounds.size = sequencerCV.collectionViewLayout.collectionViewContentSize
        
    }
    
    func setupSequencer(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 16)
        sequencerCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let sequencerCV = self.sequencerCV else { return }
        sequencerCV.register(SCSequencerCell.self, forCellWithReuseIdentifier: "SCSequencerCell")
        sequencerCV.delegate = self
        sequencerCV.dataSource = self
        contentView.addSubview(sequencerCV)
        sequencerCV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0))
         contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0))
         contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0)) 
    }
}


extension SCScoreCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
         func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let result = CGSize.init(width: sequencerCV!.frame.width/16, height: sequencerCV!.frame.height)
            return result
        }
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 4
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = sequencerCV?.dequeueReusableCell(withReuseIdentifier: "SCSequencerCell", for: indexPath) as!SCSequencerCell
        cell.backgroundColor = UIColor.white
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.white.cgColor
        cell.setupSequencer()
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
        
}
