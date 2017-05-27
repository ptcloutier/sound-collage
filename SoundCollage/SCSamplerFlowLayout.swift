//
//  SamplerLayout.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSamplerFlowLayout: UICollectionViewFlowLayout {

    var direction: UICollectionViewScrollDirection
    var numOfCol: CGFloat
    

    init(direction: UICollectionViewScrollDirection, numberOfColumns: CGFloat) {
        self.direction = direction
        self.numOfCol = numberOfColumns
        super.init()

        setupLayout()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupLayout() {
        minimumInteritemSpacing = 1
        minimumLineSpacing = 1
        scrollDirection = self.direction
    }
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns = self.numOfCol
            
            let itemWidth = (self.collectionView!.frame.width - (numberOfColumns - 1)) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
}
