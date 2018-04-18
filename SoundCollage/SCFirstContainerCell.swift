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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SCFirstContainerCell.scrollToSampler), name: NSNotification.Name(rawValue: "recordBtnDidPress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SCFirstContainerCell.scrollToSequencer), name: NSNotification.Name(rawValue: "sequencerPlaybackDidPress"), object: nil)
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let cv = self.collectionView else { return }
        cv.delegate = self
        cv.dataSource = self
        cv.register(SCMusicInterfaceCell.self, forCellWithReuseIdentifier: "SCMusicInterfaceCell")
        cv.isScrollEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.frame = self.contentView.frame
        self.contentView.addSubview(cv)
        
    }
    
    
    @objc func scrollToSampler(){
        if let cv = self.collectionView {
            let indexPath = IndexPath(item: 0, section: 0)
            cv.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
    @objc func scrollToSequencer(){
        if let cv = self.collectionView {
            let indexPath = IndexPath(item: 1, section: 0)
            cv.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
}


extension SCFirstContainerCell:  UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = CGSize.init(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        return cellSize
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


extension SCFirstContainerCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCMusicInterfaceCell", for: indexPath) as! SCMusicInterfaceCell
            cell.setupSampler()
            return cell
    }
}





extension SCFirstContainerCell: UIScrollViewDelegate {
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cv = self.collectionView {
            scrollView.snapToNearestCell(scrollView: scrollView, collectionView: cv)
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let cv = collectionView {
            scrollView.snapToNearestCell(scrollView: scrollView, collectionView: cv)
        }
    }
    
}
