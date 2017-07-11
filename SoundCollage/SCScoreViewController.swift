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
    let toolbarHeight = CGFloat(98.0)
    var toolbar = UIToolbar()
    var recordBtn: UIButton?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.orange
        // Do any additional setup after loading the view.
        setupCollectionView()
        setupControls()
    }
    
    
    func setupCollectionView(){
        
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        scoreCV = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        scoreCV?.register(SCScoreCell.self, forCellWithReuseIdentifier: "SCScoreCell")
        guard let scoreCV = self.scoreCV else { return }
        scoreCV.delegate = self
        scoreCV.dataSource = self 
        view.addSubview(scoreCV)
        
        scoreCV.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: scoreCV, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0))

    }
    
    func setupPlayerTimer(){
        
        
    }
   
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
            [weak self] flashTimer in  // creates a capture group for the timer
            guard let strongSelf = self else {  // bail out of the timer code if the cell has been freed
                return
            }
            strongSelf.triggerCell()
        }
    }
    
    
    func triggerCell(){
        
        print("/()")
        
    }

    
    
    //MARK: ui setup
    
    
    private func setupControls(){
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = toolbar.center.y-buttonHeight/2
        
        self.recordBtn = UIButton.GradientColorStyle(height: buttonHeight*0.75, gradientColors: [UIColor.red, UIColor.magenta, UIColor.orange], secondaryColor: UIColor.white)
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        recordBtn.addTarget(self, action: #selector(SCScoreViewController.recordBtnDidPress), for: .touchUpInside)
        recordBtn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let bankBtn = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral, secondaryColor: UIColor.white)
        bankBtn.addTarget(self, action: #selector(SCScoreViewController.bankBtnDidPress), for: .touchUpInside)
        
        
        let samplerBtn = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.lightBlueSky, secondaryColor: UIColor.white)
        samplerBtn.addTarget(self, action: #selector(SCScoreViewController.presentSampler), for: .touchUpInside)
        
        let playBtn = UIButton.FlatColorStyle(height: buttonHeight, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.rose, secondaryColor: UIColor.white)
        playBtn.addTarget(self, action: #selector(SCScoreViewController.playBtnDidPress), for: .touchUpInside)
        let tempBtn3 = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, secondaryColor: UIColor.white)
        
        let bankBarBtn = UIBarButtonItem.init(customView: bankBtn)
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        let samplerBarBtn = UIBarButtonItem.init(customView: samplerBtn)
        let playBarBtn = UIBarButtonItem.init(customView: playBtn)
        let tempBarBtn3 = UIBarButtonItem.init(customView: tempBtn3)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.items = [flexibleSpace, bankBarBtn, flexibleSpace, samplerBarBtn, flexibleSpace,  playBarBtn, flexibleSpace, recordBarBtn, flexibleSpace, tempBarBtn3, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    
    //MARK: Navigation
    
    func presentSampler(){
        
        let vc: SCSamplerViewController = SCSamplerViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    func recordBtnDidPress(){
        
        
    }
    
    
    
    func bankBtnDidPress(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    
    //MARK: Playback
    
    func playBtnDidPress(){
        
        print("Start sequencer.")
        
    }

}



extension SCScoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
//     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let result = CGSize.init(width: view.frame.width/16, height: view.frame.height/16)
//        return result
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = scoreCV?.dequeueReusableCell(withReuseIdentifier: "SCScoreCell", for: indexPath) as!SCScoreCell
        cell.setupSequencer()

        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    
        }
}
