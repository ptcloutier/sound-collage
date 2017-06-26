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
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img1 = UIImage.init(named: "l1")
        let img2 = UIImage.init(named: "l2")
        let img3 = UIImage.init(named: "l3")
        let img4 = UIImage.init(named: "l4")
        let img5 = UIImage.init(named: "l7")
        let img6 = UIImage.init(named: "l8")
        images = [img1!, img2!, img3!, img4!, img5!, img6!]
        
        setupTitle(xConstant: -5.0, yConstant: 0, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral )
        setupTitle(xConstant: -3.0, yConstant: 2.0, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue)
        setupTitle(xConstant: -1.0, yConstant: 4.0, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.neonAqua)
//        setupTitle(xConstant: 1.0, yConstant: 6.0, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.darkRose)
//        setupTitle(xConstant: 3.0, yConstant: 8.0, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.lightestBlueSky)
//        setupTitle(xConstant: 5.0, yConstant: 10.0, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.medViolet)

        setupControls()
        setupCollectionView()
        animateEntrance()
    }
    
    private func setupTitle(xConstant: CGFloat, yConstant: CGFloat, textColor: UIColor){
    
        let margin: CGFloat = 20.0
        let titleLabel = UILabel.init(frame: .zero)
        titleLabel.text = "C  O  N  C  R  E  A  T  E"
        titleLabel.font = UIFont.init(name: "A DAY WITHOUT SUN", size: 60.0)
        titleLabel.textColor = textColor
        titleLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.8, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.2, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: xConstant))
            self.view.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: yConstant+margin))
        
    }
    
    
    private func setupCollectionView(){
        
        let flowLayout = SCSampleBankFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(SCSampleBankCell.self, forCellWithReuseIdentifier: "SCSampleBankCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.Custom.PsychedelicIceCreamShoppe.ice
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))

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
        let standardSamplerBarBtn = setupToolbarButton(btn: newStandardSamplerBtn)
//        let doubleSamplerBtnBtn = setupToolbarButton(btn: newDoubleSamplerBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.items = [flexibleSpace, standardSamplerBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
        
        
    }
    
    
    func setupToolbarButton(btn: UIButton)-> UIBarButtonItem {
        
       
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = toolbar.center.y-buttonHeight/2
        btn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        btn.setImage(UIImage.init(named: "plus.png"), for: .normal)
        let backgroundView = UIView.init(frame: btn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        backgroundView.layer.borderWidth = 1.0
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
        let iceCreamColors: [UIColor] = SCGradientColors.getPsychedelicIceCreamShopColors()
        
        var colorIdx: Int
        if indexPath.row > iceCreamColors.count-1 {
            colorIdx = indexPath.row-iceCreamColors.count
            if colorIdx > iceCreamColors.count-1 {
                colorIdx -= iceCreamColors.count
            }
        } else {
            colorIdx = indexPath.row
        }
        var imgIdx: Int
        if indexPath.row > images.count-1 {
            imgIdx = indexPath.row - images.count
        } else {
            imgIdx = indexPath.row
        }
        cell.imageView.backgroundColor = iceCreamColors[colorIdx]
        cell.imageView.image = images[imgIdx]
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
