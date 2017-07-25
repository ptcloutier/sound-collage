//
//  SCMixerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSelectedPadCell: UICollectionViewCell {
    
    var collectionView: UICollectionView?
    var colors: [UIColor] = []

    
    
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
        cv.register(SCPadNumberCell.self, forCellWithReuseIdentifier: "SCPadNumberCell")
        cv.isScrollEnabled = true
        cv.bounces = true
        cv.frame = self.contentView.bounds
        self.contentView.addSubview(cv)
    }
}



extension SCSelectedPadCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCPadNumberCell", for: indexPath) as! SCPadNumberCell
        cell.setupLabel(title: "\(indexPath.row+1)")
        return cell
    }
}
