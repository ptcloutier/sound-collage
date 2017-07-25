//
//  SCBottomContainerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSecondContainerCell: UICollectionViewCell {
    
    var collectionView: UICollectionView?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 1)
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let cv = self.collectionView else { return }
        cv.delegate = self
        cv.dataSource = self
        cv.register(SCMusicInterfaceCell.self, forCellWithReuseIdentifier: "SCMusicInterfaceCell")
        cv.isScrollEnabled = false 
        cv.frame = self.contentView.bounds
        self.contentView.addSubview(cv)
        
    }
}



extension SCSecondContainerCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCAudioManager.shared.effectControls.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCMusicInterfaceCell", for: indexPath) as! SCMusicInterfaceCell
            cell.setupEffects()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCMusicInterfaceCell", for: indexPath) as! SCMusicInterfaceCell
            return cell
            
        }
    }
}
