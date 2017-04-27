//
//  SamplerViewController.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit
import AVFoundation
//import AudioKit



class SCSamplerViewController: UIViewController  {
    
    var collectionView: UICollectionView?
    var recordBtn = UIButton()
    var newRecordingTitle: String?
    var audioPlayer: SCAudioManager!
    var lastRecording: URL?
    var recordingTimer: Timer? = nil
    var flashingOn = false
    var selectedSampleIndex: Int?
    var gradientLayer: CAGradientLayer!
    var colorSets = [[CGColor]]()
    var currentColorSet: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupControls()
//        createColorSets()
//        createGradientLayer()
//        changeColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 
        guard let collectionView = self.collectionView else {
            print("collectionview is nil")
            return
        }
        collectionView.bounds.size = collectionView.collectionViewLayout.collectionViewContentSize
        collectionView.frame.origin.y = 80
    }
    
    private func setupCollectionView(){
        let flowLayout = SCSamplerFlowLayout()
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        guard let collectionView = self.collectionView else{
            print("Error: collectionview is nil")
            return
        }
        collectionView.register(SCSamplerCollectionViewCell.self, forCellWithReuseIdentifier: "SCSamplerCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
    }
    
    private func setupControls(){
        
        recordBtn.setBackgroundImage(UIImage.init(named: "record"), for: .normal)
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress), for: .touchUpInside)
        
        
        let tabHeight = CGFloat(49.0)
        let buttonHeight = view.frame.width/6
        let yPosition = view.frame.height-tabHeight-buttonHeight
        recordBtn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        recordBtn.center = CGPoint(x: view.center.x, y: yPosition)
        view.addSubview(recordBtn)
        
        let testBtn = UIButton.init()
        testBtn.setBackgroundImage(UIImage.init(named: "dot"), for: .normal)
        testBtn.addTarget(self, action: #selector(SCSamplerViewController.testBtnDidPress(_:)), for: .touchUpInside)
        
        
        let stabHeight = CGFloat(49.0)
        let sbuttonHeight = view.frame.width/6
        let syPosition = view.frame.height-stabHeight-sbuttonHeight
        testBtn.frame = CGRect(x: 0, y: 0, width: sbuttonHeight , height: sbuttonHeight)
        testBtn.center = CGPoint(x: view.center.x+70, y: syPosition)
        view.addSubview(testBtn)
        
    }
    
    
    
    func testBtnDidPress(_ sender: Any){
        let vc: SCKeyboardViewController = SCKeyboardViewController(nibName: nil, bundle: nil)
        SCAnimator.fadeIn(in: view)
        present(vc, animated: true, completion: nil)
    }
    
    
    
    
    //MARK: Recording and Playback

    func recordBtnDidPress(_ sender: Any) {
        
        switch SCAudioManager.shared.recordingIsEnabled { //TODO: wtf logic works but reads like shit 
        case false:
            SCAudioManager.shared.recordingIsEnabled = true // 1
        case true:
            SCAudioManager.shared.recordingIsEnabled = false
        }
        guard let cv = self.collectionView else {
            print("collectionview not found.")
            return
        }
        cv.reloadData()
    }
}


extension SCSamplerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCSamplerCollectionViewCell", for: indexPath) as! SCSamplerCollectionViewCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15.0
        // add a border
        cell.layer.borderColor = UIColor.cyan.cgColor
        cell.layer.borderWidth = 3.0
        cell.layer.cornerRadius = 15.0
        
        switch SCAudioManager.shared.recordingIsEnabled {
        case true:
            cell.recordingIsEnabled = true
        case false:
            cell.recordingIsEnabled = false
            
        }
        cell.tryTimer()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SCSamplerCollectionViewCell else {
            fatalError("Wrong cell dequeued")
        }
        //Configure the cell
        
        SCAudioManager.shared.selectedSampleIndex = indexPath.row
        
        switch SCAudioManager.shared.recordingIsEnabled {
        case true:
            SCAudioManager.shared.createNewSample()
            cell.recordingIsEnabled = false
        case false:
            SCAudioManager.shared.playback()
            cell.animateCell()
        }

    }
    
    
 
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
