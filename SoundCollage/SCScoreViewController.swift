//
//  SCScoreViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCScoreViewController: UIViewController {

    var scoreCV: UICollectionView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.orange
        // Do any additional setup after loading the view.
        setupCollectionView()
    }
    
    
    func setupCollectionView(){
        
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        scoreCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        scoreCV?.backgroundColor = UIColor.purple
        scoreCV?.register(SCScoreCell.self, forCellWithReuseIdentifier: "SCScoreCell")
        guard let scoreCV = self.scoreCV else { return }
        view.addSubview(scoreCV)
        
        scoreCV.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
//        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: <#T##NSLayoutAttribute#>, relatedBy: <#T##NSLayoutRelation#>, toItem: <#T##Any?#>, attribute: <#T##NSLayoutAttribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>))
        
        
    }
}


extension SCScoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let result = CGSize.init(width: view.frame.width/16, height: view.frame.height/16)
        return result
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = scoreCV?.dequeueReusableCell(withReuseIdentifier: "SCScoreCell", for: indexPath) as!SCScoreCell
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    
        }
}
