//
//  SCContainerViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/18/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCContainerViewController: UIViewController {

    
    var collectionView: UICollectionView?
    var recordBtn: UIButton?
    let navBarBtnFrameSize = CGRect.init(x: 0, y: 0, width: 30, height: 30)
    let toolbarHeight = CGFloat(49.0)
    var toolbar = UIToolbar()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        setupCollectionView()
        setupControls()
    }

   
    
    
    func setupCollectionView(){
        
        let flowLayout = SCSamplerFlowLayout.init(direction: .vertical, numberOfColumns: 1)
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: flowLayout)
        guard let cv = self.collectionView else { return }
        cv.delegate = self
        cv.dataSource = self
        cv.register(SCFirstContainerCell.self, forCellWithReuseIdentifier: "SCFirstContainerCell")
        cv.register(SCSecondContainerCell.self, forCellWithReuseIdentifier: "SCSecondContainerCell")
        cv.isScrollEnabled = false
        cv.frame = self.view.bounds
        self.view.addSubview(cv)

    }
    
    
    
    //MARK: ui setup
    
    
    private func setupControls(){ // record a song, see songs, go back to banks 
        
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        
        toolbar.frame = CGRect(x: 0, y: self.view.frame.height-toolbarHeight, width: self.view.frame.width, height: toolbarHeight)
        toolbar.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        toolbar.setShadowImage(transparentPixel, forToolbarPosition: .any)
        toolbar.isTranslucent = true
        
        let buttonHeight = (toolbarHeight/3)*2
        let yPosition = toolbar.center.y-buttonHeight/2
        
        self.recordBtn = UIButton.GradientColorStyle(height: buttonHeight, gradientColors: [UIColor.red, UIColor.magenta, UIColor.orange], secondaryColor: UIColor.white)
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        recordBtn.addTarget(self, action: #selector(SCContainerViewController.recordBtnDidPress), for: .touchUpInside)
        recordBtn.center = CGPoint(x: toolbar.center.x, y: yPosition)
        
        let bankBtn = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral, secondaryColor: UIColor.white)
        bankBtn.addTarget(self, action: #selector(SCContainerViewController.bankBtnDidPress), for: .touchUpInside)
        
        
        let sequencerBtn = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.lightBlueSky, secondaryColor: UIColor.white)
        sequencerBtn.addTarget(self, action: #selector(SCContainerViewController.postSequencerPlaybackDidPressNotification), for: .touchUpInside)
        
        let tempBtn2 = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.rose, secondaryColor: UIColor.white)
        
        let tempBtn3 = UIButton.FlatColorStyle(height: buttonHeight*0.75, primaryColor: UIColor.Custom.PsychedelicIceCreamShoppe.deepBlue, secondaryColor: UIColor.white)
        
        let bankBarBtn = UIBarButtonItem.init(customView: bankBtn)
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        let sequencerBarBtn = UIBarButtonItem.init(customView: sequencerBtn)
        let tempBarBtn2 = UIBarButtonItem.init(customView: tempBtn2)
        let tempBarBtn3 = UIBarButtonItem.init(customView: tempBtn3)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.items = [flexibleSpace, bankBarBtn, flexibleSpace, sequencerBarBtn, flexibleSpace,  recordBarBtn, flexibleSpace, tempBarBtn2, flexibleSpace, tempBarBtn3, flexibleSpace]
        self.view.addSubview(toolbar)
    }
    
    
    
    
    func recordBtnDidPress(){
        
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }

        switch SCAudioManager.shared.isRecording {
        case true:
            SCAudioManager.shared.finishRecording(success: true)
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        case false:
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        }
    }
    
    
    //MARK: Navigation
    
    
    func bankBtnDidPress(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    //MARK: Notifications
    
    
//    func postRecordBtnDidPressNotification(){
//        
//        NotificationCenter.default.post(name: Notification.Name.init("recordBtnDidPress"), object: nil)
//        
//    }
    

    
    func postSequencerPlaybackDidPressNotification(){
       
        NotificationCenter.default.post(name: Notification.Name.init("sequencerPlaybackDidPress"), object: nil)
    }

}


extension SCContainerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCFirstContainerCell", for: indexPath) as! SCFirstContainerCell
            cell.setupCollectionView()
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSecondContainerCell", for: indexPath) as! SCSecondContainerCell
            cell.setupCollectionView()
            return cell
        }
    }
}


