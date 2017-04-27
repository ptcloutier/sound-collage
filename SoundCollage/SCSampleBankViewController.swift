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
        animateEntrance()
    }
    
    
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    
    
    private func setupCollectionView(){
        
        let flowLayout = SCSampleBankFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(SCSampleBankCell.self, forCellWithReuseIdentifier: "SCSampleBankCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
    private func animateEntrance() {
    
        collectionView.alpha = 0
        collectionView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseInOut], animations:{[unowned self] in
            
            self.collectionView.alpha = 1.0
            self.collectionView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
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
        
        
        collectionView.transform = CGAffineTransform(scaleX: 1, y: 1)
        
           UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations:{
            collectionView.transform = CGAffineTransform(scaleX: 5, y: 5)
            
            let vc: SCSamplerViewController = SCSamplerViewController(nibName: nil, bundle: nil)
            let transition = CATransition()
            transition.duration = 1.0
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFade
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.present(vc, animated: true, completion: nil)
           }, completion: nil
            

    )
    }
}
