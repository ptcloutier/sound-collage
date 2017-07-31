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
    let cellCount: Int = 17
    
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
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: CGFloat(cellCount))
        sequencerCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let sequencerCV = self.sequencerCV else { return }
        
        sequencerCV.register(SCSequencerCell.self, forCellWithReuseIdentifier: "SCSequencerCell")
        sequencerCV.delegate = self
        sequencerCV.dataSource = self
        contentView.addSubview(sequencerCV)
        sequencerCV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: sequencerCV, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0))
    }
}


extension SCScoreCell:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
         func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let result = CGSize.init(width: sequencerCV!.frame.width/CGFloat(cellCount), height: sequencerCV!.frame.height)
            return result
        }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = sequencerCV?.dequeueReusableCell(withReuseIdentifier: "SCSequencerCell", for: indexPath) as!SCSequencerCell

        cell.idx = indexPath.row
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.darkGray.cgColor//UIColor.purple.cgColor
        cell.setupSequencer()
        return cell

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
        
}
