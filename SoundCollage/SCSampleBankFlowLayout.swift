//
//  SCSamplerBankFlowLayout.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/23/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSampleBankFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        minimumInteritemSpacing = 3
        minimumLineSpacing = 3
        scrollDirection = .horizontal
    }
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 1
            
            let itemWidth = (self.collectionView!.frame.width - (numberOfColumns - minimumLineSpacing)) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
}
