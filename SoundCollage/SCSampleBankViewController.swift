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
    let toolbarHeight: CGFloat = 98.0
    var toolbar = UIToolbar()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
        setupCollectionView()
        animateEntrance()
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
    
    
    
    
    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        let newStandardSamplerBtn = UIButton()
        newStandardSamplerBtn.addTarget(self, action: #selector(SCSampleBankViewController.newStandardSamplerDidPress), for: .touchUpInside)
        let newDoubleSamplerBtn = UIButton()
        newDoubleSamplerBtn.addTarget(self, action: #selector(SCSampleBankViewController.newDoubleSamplerDidPress), for: .touchUpInside)
        let standardBarBtn = setupToolbarButton(btn: newStandardSamplerBtn)
        let doubleBarBtn = setupToolbarButton(btn: newDoubleSamplerBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.items = [flexibleSpace, standardBarBtn, flexibleSpace, doubleBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
        
        
    }
    
    
    func setupToolbarButton(btn: UIButton)-> UIBarButtonItem {
        
       
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = toolbar.center.y-buttonHeight/2
        btn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        let backgroundView = UIView.init(frame: btn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.applyGradient(withColors: [UIColor.red, UIColor.magenta, UIColor.orange], gradientOrientation: .topLeftBottomRight)
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.borderWidth = 3.0
        backgroundView.layer.borderColor = UIColor.purple.cgColor
        btn.addSubview(backgroundView)
        btn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        let barBtn = UIBarButtonItem.init(customView: btn)

       return barBtn
        
    }
    
    
    
    func newStandardSamplerDidPress(){
      
        let samplerType = SCSampleBank.SamplerType.standard
        newSampler(samplerType: samplerType)
    }
    
    

    func newDoubleSamplerDidPress(){
        let samplerType = SCSampleBank.SamplerType.double
        newSampler(samplerType: samplerType)
    }
    
    
    private func newSampler(samplerType: SCSampleBank.SamplerType){
        var samples: [String: AnyObject]
        
        switch samplerType {
        case .standard:
            samples = SCDataManager.shared.newStandardSampleBank()
        case .double:
            samples = SCDataManager.shared.newDoubleSampleBank()
        }
        
        let sampleBankID = SCDataManager.shared.getSampleBankID()
        let sampleBank = SCSampleBank.init(name: nil, id: sampleBankID, samples: samples, type: samplerType)
        SCDataManager.shared.user?.sampleBanks?.append(sampleBank)
        SCDataManager.shared.user?.currentSampleBank = SCDataManager.shared.user?.sampleBanks?.last
        presentSampler()
    }
    
    
    
    func presentSampler(){
        
        self.collectionView.transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations:{
            self.collectionView.transform = CGAffineTransform(scaleX: 5, y: 5)
            
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





extension SCSampleBankViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        guard let sampleBanks = SCDataManager.shared.user?.sampleBanks else {
            print("Error: could not load sampler, sample bank not found")
            return 1
        }
        return sampleBanks.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSampleBankCell", for: indexPath) as! SCSampleBankCell
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let sampleBanks = SCDataManager.shared.user?.sampleBanks else {
            print("Error: could not load sampler, sample bank not found")
            return
        }
        
        SCDataManager.shared.user?.currentSampleBank = sampleBanks[indexPath.row]
        presentSampler()
    }
}
