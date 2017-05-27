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
        self.contentView.backgroundColor = UIColor.purple
        effects = ["reverb", "delay", "distortion"]
        setupCollectionView()
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 3)
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: flowLayout)
        guard let cv = self.collectionView else {
            print("No collectionview.")
            return
        }
        self.contentView.addSubview(cv)
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
        print("Effect picker cell override")
    }
}
