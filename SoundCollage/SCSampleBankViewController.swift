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
        collectionView.register(SCSampleBankCell.self, forCellWithReuseIdentifier: "SCSampleBankCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

extension SCSampleBankViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let user = SCDataManager.shared.user else {
            print("Error: could not load sampler, user not found")
            return 1
        }
        guard let sampleBanks = user.sampleBanks else {
            print("Error: could not load sampler, sample bank not found")
            return 1
        }
        return sampleBanks.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSampleBankCell", for: indexPath) as! SCSampleBankCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: SCSamplerViewController = SCSamplerViewController(nibName: nil, bundle: nil)
        SCAnimator.fadeIn(in: view)
        present(vc, animated: true, completion: nil)
    }
}
