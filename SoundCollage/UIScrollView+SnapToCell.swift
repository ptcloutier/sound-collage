//
//  UIScrollView+SnapToCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/31/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    
    func snapToNearestCell(scrollView: UIScrollView, collectionView: UICollectionView?) {
        
        //pick first cell to get width
        let indexPath = IndexPath(item: 0, section: 0)
        guard let cv = collectionView else { return }
        
        if let cell = cv.cellForItem(at: indexPath){
            
            let cellWidth = cell.bounds.size.width
            
            for i in 0..<cv.numberOfItems(inSection: 0) {
                if scrollView.contentOffset.x <= CGFloat(i) * cellWidth + cellWidth / 2 {
                    let indexPath = IndexPath(item: i, section: 0)
                    cv.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    break
                }
            }
        }
    }
}
