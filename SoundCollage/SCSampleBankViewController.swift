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
        
      
        
//        setupTitle(xConstant: 0, yConstant:  0, textColor: UIColor.white)
//        let ta1 = [CGFloat(50.0), CGFloat(17.0), CGFloat(8.0), CGFloat(2.0), SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral, SCColor.Custom.PsychedelicIceCreamShoppe.deepBlueShade] as [Any]
//        let ta2 = [CGFloat(45.0), CGFloat(18.0), CGFloat(7.0), CGFloat(2.0), SCColor.Custom.PsychedelicIceCreamShoppe.medRose, SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet] as [Any]
//        let ta3 = [CGFloat(40.0), CGFloat(19.0), CGFloat(6.0), CGFloat(3.0), SCColor.Custom.PsychedelicIceCreamShoppe.darkRose, SCColor.Custom.PsychedelicIceCreamShoppe.lightRose] as [Any]
        let ta4 = [CGFloat(45.0), CGFloat(50.0), CGFloat(8.0), CGFloat(1.0), SCColor.Custom.PsychedelicIceCreamShoppe.rose, SCColor.Custom.PsychedelicIceCreamShoppe.rose] as [Any]
//        let ta5 = [CGFloat(35.0), CGFloat(35.0), CGFloat(3.0), CGFloat(3.0), SCColor.Custom.PsychedelicIceCreamShoppe.lightCoral, SCColor.Custom.PsychedelicIceCreamShoppe.lightCoral] as [Any]
//        let ta6 = [CGFloat(30.0), CGFloat(45.0), CGFloat(1.0), CGFloat(8.0), SCColor.Custom.PsychedelicIceCreamShoppe.medRose, SCColor.Custom.PsychedelicIceCreamShoppe.rose] as [Any]
//        let ta7 = [CGFloat(20.0), CGFloat(35.0), CGFloat(2.0), CGFloat(8.0), SCColor.Custom.PsychedelicIceCreamShoppe.lightRose, SCColor.Custom.PsychedelicIceCreamShoppe.medRose] as [Any]
//        let ta8 = [CGFloat(19.0), CGFloat(40.0), CGFloat(2.0), CGFloat(9.0), SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet, SCColor.Custom.PsychedelicIceCreamShoppe.darkRose] as [Any]
//        let ta9 = [CGFloat(18.0), CGFloat(45.0), CGFloat(2.0), CGFloat(9.0), SCColor.Custom.PsychedelicIceCreamShoppe.deepBlueShade, SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral] as [Any]
//        let ta10 = [CGFloat(17.0), CGFloat(50.0), CGFloat(2.0), CGFloat(9.0), SCColor.Custom.PsychedelicIceCreamShoppe.darkViolet, SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral] as [Any]

        // label1 fontSize, label2 fontSize, label1 alpha, label2 alpha , label1textColor, label2textColor
//        setupTitle(xConstant: -50, yConstant: 0, textAttributes: ta1)
//        setupTitle(xConstant: -35, yConstant: 20, textAttributes: ta2)
//        setupTitle(xConstant: -20, yConstant: 40, textAttributes: ta3)
        setupTitle(xConstant: 0, yConstant: 0, textAttributes: ta4)
//        setupTitle(xConstant:  10, yConstant: 20, textAttributes: ta5)
//        setupTitle(xConstant: 25, yConstant: 40, textAttributes: ta6)
//        setupTitle(xConstant: 40, yConstant: 120, textAttributes: ta7)
//        setupTitle(xConstant: 55, yConstant: 140, textAttributes: ta8)
//        setupTitle(xConstant: 60, yConstant: 160, textAttributes: ta9)
//        setupTitle(xConstant: 75, yConstant: 180, textAttributes: ta10)
//        setupTitle(xConstant: 34, yConstant: 120, textAttributes: ta7, alpha: 0.5)
//        setupTitle(xConstant: 30, yConstant: 140, textAttributes: ta8, alpha: 0.4)
//        setupTitle(xConstant: 25, yConstant: 160, textAttributes: ta9, alpha: 0.7)
//        setupTitle(xConstant: 20, yConstant: 120, textAttributes: ta10, alpha: 0.5)
//        setupTitle(xConstant: 15, yConstant: 140, textAttributes: ta11, alpha: 0.4)
//        setupTitle(xConstant: 10, yConstant: 160, textAttributes: ta12, alpha: 0.7)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupControls()
     }
    
     
    
    //MARK: ui setup
    
    private func setupTitle(xConstant: CGFloat, yConstant: CGFloat, textAttributes: [Any]){
    
        let label1fontSize = textAttributes[0] as! CGFloat
        let label2fontSize = textAttributes[1] as! CGFloat
        let label1Alpha = textAttributes[2] as! CGFloat
        let label2Alpha = textAttributes[3] as! CGFloat
        let label1textColor = textAttributes[4] as! UIColor
        let label2textColor = textAttributes[5] as! UIColor
        
        
        let margin: CGFloat = 20.0
        let titleLabel1 = UILabel.init(frame: .zero)
        titleLabel1.text = "S O U N D"
        titleLabel1.font = UIFont.init(name: "Futura", size: label1fontSize)
        titleLabel1.textColor = label1textColor
        titleLabel1.textAlignment = NSTextAlignment.center
        titleLabel1.addGlow(color: label2textColor)
        titleLabel1.alpha = label1Alpha
        self.collectionView.addSubview(titleLabel1)
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: xConstant))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel1, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: (yConstant+(margin*2.0))))
        
        let titleLabel2 = UILabel.init(frame: .zero)
        titleLabel2.text = "C O L L A G E"
        titleLabel2.font = UIFont.init(name: "Futura", size: label2fontSize)
        titleLabel2.textColor = label2textColor
        titleLabel2.textAlignment = NSTextAlignment.center
        titleLabel2.addGlow(color: label2textColor)
        titleLabel2.alpha = label2Alpha
        self.collectionView.addSubview(titleLabel2)
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .top, relatedBy: .equal, toItem: titleLabel1, attribute: .bottom, multiplier: 1.0, constant: 0))// 100+yConstant))
    }
    
    
    private func setupCollectionView(){
        
        let flowLayout = SCSampleBankFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(SCSampleBankCell.self, forCellWithReuseIdentifier: "SCSampleBankCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = SCColor.Custom.Gray.dark
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false 
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
        
        let newSamplerBtn = UIButton()
        newSamplerBtn.addTarget(self, action: #selector(SCSampleBankViewController.newSamplerDidPress), for: .touchUpInside)
        
    
        let newSamplerBarBtn = setupToolbarButton(btn: newSamplerBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [flexibleSpace, newSamplerBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    

    
    
    func setupToolbarButton(btn: UIButton)-> UIBarButtonItem {
        
        let buttonHeight = toolbarHeight
        let yPosition = toolbar.center.y-buttonHeight/2
        
        btn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        btn.setImage(UIImage.init(named: "plus1"), for: .normal)
        
        let backgroundView = UIView.init(frame: btn.frame)
        backgroundView.isUserInteractionEnabled = false
        backgroundView.layer.cornerRadius = buttonHeight/2
        backgroundView.layer.masksToBounds = true
        btn.addSubview(backgroundView)
        btn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let barBtn = UIBarButtonItem.init(customView: btn)
        return barBtn
    }
    
    
   

    
    
    func newSamplerDidPress(){
        
        let dm = SCDataManager.shared
        
        dm.createNewSampleBank()
        dm.currentSampleBank = (dm.user?.sampleBanks?.count)!-1
        
        collectionView.reloadData()
        scrollToNewSampleBank(index: dm.currentSampleBank!)
    }
    
    
    
    
    private func scrollToNewSampleBank(index: Int) {
        
        if let cv = self.collectionView {
            let indexPath = IndexPath(item: index, section: 0)
            cv.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    

    
    func setupCurrentSampleBankEffectSettings(){

        SCAudioManager.shared.audioController = SCGAudioController.init()
        SCAudioManager.shared.audioController?.delegate = SCAudioManager.shared as? SCGAudioControllerDelegate

        SCAudioManager.shared.audioController?.getAudioFilesForURL()
        SCAudioManager.shared.effectControls = (SCDataManager.shared.user?.sampleBanks?[SCDataManager.shared.currentSampleBank!].effectSettings)!
        SCAudioManager.shared.audioController?.effectControls = SCAudioManager.shared.effectControls
    }
    
    
    
    func presentSampler(){
        
        let dm = SCDataManager.shared
        let currentSB = dm.user?.sampleBanks?[dm.currentSampleBank!]

        print("Current sample bank \(String(describing: currentSB.debugDescription))")

        let vc: SCContainerViewController = SCContainerViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 2.0, fromVC: self, toVC: vc)
    }
}





extension SCSampleBankViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        guard let sampleBanks = SCDataManager.shared.user?.sampleBanks else {
//            print("Error: could not load sampler, sample bank not found")
            return 0
        }
        return sampleBanks.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSampleBankCell", for: indexPath) as! SCSampleBankCell
        let iceCreamColors: [UIColor] = SCColor.getPsychedelicIceCreamShopColors()
        
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
        cell.imageView.backgroundColor =  UIColor.white //iceCreamColors[colorIdx] 
        cell.imageView.image = images[imgIdx]
        
        let dm = SCDataManager.shared
        cell.id = dm.user?.sampleBanks?[indexPath.row].id
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SCSampleBankCell
        cell
        
        let dm = SCDataManager.shared
        dm.currentSampleBank = indexPath.row
        for sb in (SCDataManager.shared.user?.sampleBanks)! {
            if sb.id == cell.id {
                setupCurrentSampleBankEffectSettings()
                presentSampler()
                return
            }
        }
    }
}
