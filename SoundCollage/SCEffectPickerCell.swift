//
//  SCEffectPickerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 5/27/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCEffectPickerCell: UICollectionViewCell {
    
    
    var collectionView: UICollectionView?
    var effects: [String] = []
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        effects = ["pitch up"]
        setupCollectionView()
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: flowLayout)
        guard let cv = self.collectionView else {
            print("No collectionview.")
            return
        }
        self.contentView.addSubview(cv)
        cv.showsHorizontalScrollIndicator = false
        cv.register(SCEffectCell.self, forCellWithReuseIdentifier: "EffectCell")
        cv.delegate = self
        cv.dataSource = self
    }
    
}

extension SCEffectPickerCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       print("\(effects.count)")
        return effects.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as! SCEffectCell
        cell.setupLabel(title: effects[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCEffectCell else {
            print("Wrong cell or no cell at indexPath.")
            return
        }
        cell.toggleEffect()
        print("\(effects[indexPath.row]) effect chosen.")
    }
}
