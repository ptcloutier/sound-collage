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
    let cellCount: Int = 9
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    
    
    func setupSequencer(){
        

        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: CGFloat(cellCount))
        sequencerCV = UICollectionView.init(frame: self.contentView.frame, collectionViewLayout: flowLayout)
        guard let sequencerCV = self.sequencerCV else { return }
        contentView.backgroundColor = UIColor.clear
        sequencerCV.backgroundColor = UIColor.clear
        sequencerCV.isScrollEnabled = false 
        sequencerCV.register(SCSequencerCell.self, forCellWithReuseIdentifier: "SCSequencerCell")
        sequencerCV.delegate = self
        sequencerCV.dataSource = self
        contentView.addSubview(sequencerCV)
      }
}




extension SCScoreCell: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let result = CGSize.init(width: collectionView.frame.width/CGFloat(cellCount), height: collectionView.frame.height)
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





extension SCScoreCell:  UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = sequencerCV?.dequeueReusableCell(withReuseIdentifier: "SCSequencerCell", for: indexPath) as!SCSequencerCell

        cell.idx = indexPath.row
        cell.setupSequencer()
        return cell

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
        
}








