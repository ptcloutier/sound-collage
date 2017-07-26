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
    var window: UIWindow?
    var timer = Timer()

    
    //MARK: vc life cycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        let img1 = UIImage.init(named: "l1")
        let img2 = UIImage.init(named: "l2")
        let img3 = UIImage.init(named: "l3")
        let img4 = UIImage.init(named: "l4")
        let img5 = UIImage.init(named: "l7")
        let img6 = UIImage.init(named: "l8")
        images = [img1!, img2!, img3!, img4!, img5!, img6!]
    
        setupCollectionView()
        setupTitle(xConstant: 2, yConstant: 2, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral )
        setupTitle(xConstant: 6, yConstant: 6, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue)
        setupTitle(xConstant: 10, yConstant: 10, textColor: UIColor.Custom.PsychedelicIceCreamShoppe.neonAqua)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupControls()
     }
    
     
    
    //MARK: ui setup
    
    private func setupTitle(xConstant: CGFloat, yConstant: CGFloat, textColor: UIColor){
    
        let margin: CGFloat = 20.0
        let titleLabel1 = UILabel.init(frame: .zero)
        titleLabel1.text = "S O U N D"
        titleLabel1.font = UIFont.init(name: "Futura", size: 40.0)
        titleLabel1.textColor = textColor
        titleLabel1.textAlignment = NSTextAlignment.center
        self.collectionView.addSubview(titleLabel1)
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: xConstant))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: yConstant+margin))
        
        let titleLabel2 = UILabel.init(frame: .zero)
        titleLabel2.text = "C O L L A G E"
        titleLabel2.font = UIFont.init(name: "Futura", size: 40.0)
        titleLabel2.textColor = textColor
        titleLabel2.textAlignment = NSTextAlignment.center
        self.collectionView.addSubview(titleLabel2)
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: xConstant))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .top, relatedBy: .equal, toItem: titleLabel1, attribute: .bottom, multiplier: 1.0, constant: margin/2))
    }
    
    
    private func setupCollectionView(){
        
        let flowLayout = SCSampleBankFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(SCSampleBankCell.self, forCellWithReuseIdentifier: "SCSampleBankCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.black//Custom.PsychedelicIceCreamShoppe.ice
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))

    }
    
   
    

    
    private func setupControls(){
    
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        let newStandardSamplerBtn = UIButton()
        newStandardSamplerBtn.addTarget(self, action: #selector(SCSampleBankViewController.newStandardSamplerDidPress), for: .touchUpInside)
        
        let standardSamplerBarBtn = setupToolbarButton(btn: newStandardSamplerBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [flexibleSpace, standardSamplerBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    
    
    func setupToolbarButton(btn: UIButton)-> UIBarButtonItem {
        
        let buttonHeight = toolbarHeight
        let yPosition = toolbar.center.y-buttonHeight/2
        
        btn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        btn.setImage(UIImage.init(named: "plus-1"), for: .normal)
        
        let backgroundView = UIView.init(frame: btn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        btn.addSubview(backgroundView)
        btn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let barBtn = UIBarButtonItem.init(customView: btn)
        return barBtn
    }
    
    
   

    
    
    
    func dissolve(){

        UIView.animate(withDuration: 0.3, delay: 0, options: [.transitionCrossDissolve], animations:{
            self.collectionView.backgroundColor = UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral
        },
                       completion: { (finished: Bool) in
                        UIView.animate(withDuration: 0.1, delay: 0, options: [.transitionCrossDissolve], animations:{
                            self.presentSampler()

                        })
        })
    }
    
    
    
    func newStandardSamplerDidPress(){
      
        let samplerType = SCSampleBank.SamplerType.standard
        newSampler(samplerType: samplerType)
    }
    
    
    
    
    
    private func newSampler(samplerType: SCSampleBank.SamplerType){
        
        let samples = SCDataManager.shared.newStandardSampleBank()
        let sampleBankID = SCDataManager.shared.getSampleBankID()
        
        let score: [[Bool]] = SCDataManager.shared.setupScorePage()
        let sequencerSettings = SCSequencerSettings.init(score: score)
        let effectSettings: [SCEffectControl] = []
        let sampleBank = SCSampleBank.init(name: nil, id: sampleBankID, samples: samples, type: samplerType, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        SCDataManager.shared.user?.sampleBanks?.append(sampleBank)
        SCDataManager.shared.user?.currentSampleBank = SCDataManager.shared.user?.sampleBanks?.last
        presentSampler()
    }
    
    
    
    
    func presentSampler(){
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseOut], animations:{
            let vc: SCContainerViewController = SCContainerViewController(nibName: nil, bundle: nil)
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
        cell.imageView.backgroundColor = iceCreamColors[colorIdx] // TODO: image should have alpha .5
        cell.imageView.image = images[imgIdx]
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let sampleBanks = SCDataManager.shared.user?.sampleBanks else {
            print("Error: could not load sampler, sample bank not found")
            return
        }
        
        SCDataManager.shared.user?.currentSampleBank = sampleBanks[indexPath.row]
        guard let effectSettings = SCDataManager.shared.user?.currentSampleBank?.effectSettings else {
            return
        }
        SCAudioManager.shared.effectControls = effectSettings
        self.dissolve()
    }
}
