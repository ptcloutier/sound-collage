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
    let toolbarHeight = CGFloat(77.0)
    var toolbar = SCToolbar()

    
    
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
    
    
    private func setupControls(){ 
        
        toolbar.transparentToolbar(view: view, toolbarHeight: toolbarHeight)
        let buttonHeight = (toolbarHeight/3)*2

        self.recordBtn = UIButton.GradientColorStyle(height: buttonHeight, gradientColors: [UIColor.red, UIColor.magenta, UIColor.orange], secondaryColor: UIColor.white)

        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        recordBtn.addGlow(color: SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral)
        recordBtn.setBackgroundImage(UIImage.init(named: "record"), for: .normal)
        recordBtn.addTarget(self, action: #selector(SCContainerViewController.recordBtnDidPress), for: .touchUpInside)
        
        let bankBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        bankBtn.setBackgroundImage(UIImage.init(named: "sampleBank"), for: .normal)
        bankBtn.addTarget(self, action: #selector(SCContainerViewController.bankBtnDidPress), for: .touchUpInside)
        bankBtn.addGlow(color: UIColor.white)
        
        let sequencerBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        sequencerBtn.setBackgroundImage(UIImage.init(named: "play"), for: .normal)
        sequencerBtn.addTarget(self, action: #selector(SCContainerViewController.postSequencerPlaybackDidPressNotification), for: .touchUpInside)
        sequencerBtn.addGlow(color: UIColor.white)
        
        let libraryBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        libraryBtn.setBackgroundImage(UIImage.init(named: "playlist"), for: .normal)
        libraryBtn.addTarget(self, action: #selector(SCContainerViewController.libraryBtnDidPress), for: .touchUpInside)
        libraryBtn.addGlow(color: UIColor.white)
        
        let recordNewSCBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        recordNewSCBtn.setBackgroundImage(UIImage.init(named: "lp1"), for: .normal)
        recordNewSCBtn.addTarget(self, action: #selector(SCContainerViewController.recordMixerOutputBtnDidPress), for: .touchUpInside)
        recordNewSCBtn.addGlow(color: UIColor.white)
        
        let bankBarBtn = UIBarButtonItem.init(customView: bankBtn)
        let recordBarBtn = UIBarButtonItem.init(customView: recordBtn)
        let sequencerBarBtn = UIBarButtonItem.init(customView: sequencerBtn)
        let libraryBarBtn = UIBarButtonItem.init(customView: libraryBtn)
        let recordNewSCBarBtn = UIBarButtonItem.init(customView: recordNewSCBtn)
        
        let flexibleSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [ flexibleSpace, bankBarBtn, flexibleSpace, sequencerBarBtn, flexibleSpace,  recordBarBtn, flexibleSpace,  libraryBarBtn, flexibleSpace, recordNewSCBarBtn, flexibleSpace ]
        self.view.addSubview(toolbar)
        toolbar.backgroundColor = SCColor.Custom.Gray.dark
    }
    
    
    //MARK: Navigation
    
    
    func recordBtnDidPress(){
        
        guard let recordBtn = self.recordBtn else {
            print("No record btn.")
            return
        }
        postRecordBtnDidPressNotification()
        
        switch SCAudioManager.shared.isRecording {
        case true:
            SCAudioManager.shared.audioController?.isRecordingSelected = false
            SCAudioManager.shared.stopRecordingSample()
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        case false:
            SCAudioManager.shared.audioController?.engine?.pause()
            SCAudioManager.shared.audioController?.isRecordingSelected = true
            recordBtn.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations:{
                recordBtn.alpha = 1
            }, completion: nil)
        }
    }
    
    
    
    
    func bankBtnDidPress(){
        
        SCAudioManager.shared.audioController?.engine?.pause()
        SCAudioManager.shared.audioController?.engine?.reset()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController else {
            print("SampleBank vc not found.")
            return
        }
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
    }
    
    
    
    func libraryBtnDidPress(){
        
        print("library button pressed.")
        let vc: SCLibraryViewController = SCLibraryViewController(nibName: nil, bundle: nil)
        SCAnimator.FadeIn(duration: 1.0, fromVC: self, toVC: vc)
        
    }
    
    
    
    func recordMixerOutputBtnDidPress(){
        
        print("new recording sound collage did press.")
        
        switch SCAudioManager.shared.isRecordingMixerOutput {
        case true:
            SCAudioManager.shared.audioController?.stopRecordingMixerOutput()
            SCAudioManager.shared.isRecordingMixerOutput = false
        case false:
            SCAudioManager.shared.audioController?.startRecordingMixerOutput()
            SCAudioManager.shared.isRecordingMixerOutput = true
        }
    }
    
    
    
    //MARK: Notifications
    
    
    func postRecordBtnDidPressNotification(){
        print("sup")
        NotificationCenter.default.post(name: Notification.Name.init("recordBtnDidPress"), object: nil)
        NotificationCenter.default.post(name: Notification.Name.init("ScrollToSamplerNotification"), object: nil)
    }
    

    
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


