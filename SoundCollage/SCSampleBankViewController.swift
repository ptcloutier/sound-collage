//
//  SoundsViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSampleBankViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()

    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    func setupCollectionView(){
        
        let flowLayout = SCSampleBankFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(UINib.init(nibName: "SCSampleBankCell", bundle: nil), forCellWithReuseIdentifier: "SCSampleBankCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension SCSampleBankViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SCDataManager.shared.sampleBanks.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSampleBankCell", for: indexPath) as! SCSampleBankCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var sampleBank = SCSampleBank()
        if SCDataManager.shared.sampleBanks.count > 1 {
            sampleBank = SCDataManager.shared.sampleBanks[indexPath.row]
        } else {
            sampleBank = SCSampleBank()
            SCDataManager.shared.sampleBanks.append(sampleBank)
        }
        let vc: SCSamplerViewController = SCSamplerViewController(nibName: nil, bundle: nil)
        SCDataManager.shared.currentSampleBank = sampleBank
        vc.sampleBank = sampleBank
        SCAnimator.fadeIn(in: view)
        present(vc, animated: true, completion: nil)
    }
    
    
}
