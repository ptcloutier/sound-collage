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
    var user: SCUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let samples: [SCSample] = []
        let name = UUID.init().uuidString
        let sampleBank = SCSampleBank.init(name: name, id: 1, samples: samples)
        
        user.sampleBanks?.append(sampleBank)
        
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
        return user.sampleBanks!.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSampleBankCell", for: indexPath) as! SCSampleBankCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        cell.setupImageView(user: user)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var sampleBank: SCSampleBank?
        if (user.sampleBanks?.count)! > 0 {
            sampleBank = user.sampleBanks?[indexPath.row]
        } else {
            let samples: [SCSample] = []
            let name = UUID.init().uuidString
            sampleBank = SCSampleBank.init(name: name, id: 1, samples: samples)
            
        }
        user.currentSampleBank = sampleBank
        let vc: SCSamplerViewController = SCSamplerViewController(nibName: nil, bundle: nil)
        vc.user = user
        SCAnimator.fadeIn(in: view)
        present(vc, animated: true, completion: nil)
    }
    
    
}
