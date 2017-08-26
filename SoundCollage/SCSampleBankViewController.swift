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
    var toolbar = SCToolbar()
    var images: [UIImage] = []
    var window: UIWindow?
    var timer = Timer()
    var titleLabels1: [UILabel] = []
    
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
        
        createTitleLabels()
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupControls()
     }
    
     
    
    //MARK: ui setup
 
    
    
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
    
        let buttonHeight = (toolbarHeight/3)*2
//        let yPosition = toolbar.center.y-buttonHeight/2
        
        toolbar.transparentToolbar(view: view, toolbarHeight: toolbarHeight)
        let newSamplerBtn = UIButton()
        newSamplerBtn.addGlow(color: SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet)
        newSamplerBtn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        newSamplerBtn.setImage(UIImage.init(named: "plus1"), for: .normal)
        newSamplerBtn.addTarget(self, action: #selector(SCSampleBankViewController.newSamplerBtnDidPress), for: .touchUpInside)
        
        
        let libraryBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        libraryBtn.setBackgroundImage(UIImage.init(named: "playlist"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(SCSampleBankViewController.libraryBtnDidPress), for: .touchUpInside)
        libraryBtn.addGlow(color: SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet)

        let newSamplerBarBtn = UIBarButtonItem.init(customView: newSamplerBtn)//setupToolbarButton(btn: newSamplerBtn)
        let libraryBarBtn = UIBarButtonItem.init(customView: libraryBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.items = [flexibleSpace, newSamplerBarBtn, flexibleSpace, libraryBarBtn, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    //MARK: Navigation
    
    func libraryBtnDidPress(){
        
        print("library button pressed.")
        let vc: SCLibraryViewController = SCLibraryViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
        
    }

    

    
    
    func newSamplerBtnDidPress(){
        
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
        SCAudioManager.shared.isSetup = true 
    }
    
    
    
    func presentSampler(){
        
        let dm = SCDataManager.shared
        let currentSB = dm.user?.sampleBanks?[dm.currentSampleBank!]

        print("Current sample bank \(String(describing: currentSB.debugDescription))")

        let vc: SCContainerViewController = SCContainerViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 2.0, fromVC: self, toVC: vc)
    }
    
    
    
    func createTitleLabels(){

        let ta4 = [CGFloat(40.0), CGFloat(40.0), SCColor.Custom.PsychedelicIceCreamShoppe.rose, SCColor.Custom.PsychedelicIceCreamShoppe.rose] as [Any]
        setupTitle(xConstant: 0, yConstant: 0, textAttributes: ta4)
    }
    
    
    
    private func setupTitle(xConstant: CGFloat, yConstant: CGFloat, textAttributes: [Any]) {
        
        let label1fontSize = textAttributes[0] as! CGFloat
        let label2fontSize = textAttributes[1] as! CGFloat
        let label1textColor = textAttributes[2] as! UIColor
        let label2textColor = textAttributes[3] as! UIColor
        
        
        let margin: CGFloat = 20.0
        let titleLabel1 = UILabel.init(frame: .zero)
        titleLabel1.text = "S O U N D"
        titleLabel1.font = UIFont.init(name: "Futura", size: label1fontSize)
        titleLabel1.textColor = label1textColor
        titleLabel1.textAlignment = NSTextAlignment.center
        titleLabel1.addGlow(color: label2textColor)
        self.collectionView.addSubview(titleLabel1)
        view.sendSubview(toBack: titleLabel1)
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
        self.collectionView.addSubview(titleLabel2)
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: titleLabel2, attribute: .top, relatedBy: .equal, toItem: titleLabel1, attribute: .bottom, multiplier: 1.0, constant: 0))// 100+yConstant))
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
//        cell.id = dm.user?.sampleBanks?[indexPath.row].sbID
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SCSampleBankCell
        let dm = SCDataManager.shared
        dm.currentSampleBank = indexPath.row
//        for sb in (SCDataManager.shared.user?.sampleBanks)! {
//            if sb.sbID == cell.id {
                dm.setLastSampleBankIdx()
                dm.setupCurrentSampleBankEffectSettings()
                presentSampler()
                return
//            }
//        }
    }
}
