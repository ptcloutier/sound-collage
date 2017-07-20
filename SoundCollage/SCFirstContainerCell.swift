//
//  SCTopContainerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCFirstContainerCell: UICollectionViewCell {
    
    
    var collectionView: UICollectionView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let cv = self.collectionView else { return }
        cv.delegate = self
        cv.dataSource = self
        cv.register(SCMusicInterfaceCell.self, forCellWithReuseIdentifier: "SCMusicInterfaceCell")
        cv.isScrollEnabled = true
        cv.frame = self.contentView.bounds
        self.contentView.addSubview(cv)
        
    }
}



extension SCFirstContainerCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCMusicInterfaceCell", for: indexPath) as! SCMusicInterfaceCell
            cell.setupSampler()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCMusicInterfaceCell", for: indexPath) as! SCMusicInterfaceCell
            cell.setupSequencer()
            return cell
            
        }
    }
}

