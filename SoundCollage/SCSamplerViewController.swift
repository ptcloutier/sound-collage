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


class SCSamplerViewController: UIViewController, AVAudioRecorderDelegate  {
    
    var collectionView: UICollectionView?
    var shimmeringView = FBShimmeringView()
    var recordBtn = UIButton()
    var newRecordingTitle: String?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var gradientLayer: CAGradientLayer!
    var audioPlayer: SCAudioPlayer!
    var lastRecording: URL?
    var recordingIsEnabled = false
    var recordingTimer: Timer? = nil
    var flashingOn = false
    var audioFilename: URL?
    var selectedSampleIndex: Int?
    var colorManager: SCColors?
    var colorSets = [[CGColor]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        createColorSets()
        colorManager = SCColors.init(colors: colorSets)
        let startPoint = CGPoint(x: 0.0, y: 0.0)
        let endPoint = CGPoint(x: 1.0, y: 1.0)
        colorManager?.configureGradientLayer(in: self.view, from: startPoint, to: endPoint)
        setupCollectionView()
        setupControls()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Create our custom flow layout that evenly space out the items, and have them in the center
        guard collectionView != nil else {
            print("collectionview is nil")
            return
        }
        collectionView?.bounds.size = (collectionView?.collectionViewLayout.collectionViewContentSize)!
        collectionView?.frame.origin.y = 80
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    private func setupCollectionView(){
        let flowLayout = SCSamplerFlowLayout()
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        guard collectionView != nil else{
            print("collectionview is nil")
            return
        }
        collectionView?.register(SCSamplerCollectionViewCell.self, forCellWithReuseIdentifier: "SCSamplerCollectionViewCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.view.addSubview(collectionView!)
    }
    
    private func setupControls(){
        
        recordBtn.setBackgroundImage(UIImage.init(named: "record"), for: .normal)
        recordBtn.addTarget(self, action: #selector(SCSamplerViewController.recordBtnDidPress(_:)), for: .touchUpInside)
        
        
        guard let tabHeight = self.tabBarController?.tabBar.frame.height else {
            return
        }
        let buttonHeight = view.frame.width/6
        let yPosition = view.frame.height-tabHeight-buttonHeight
        recordBtn.frame = CGRect(x: 0, y: 0, width: buttonHeight , height: buttonHeight)
        recordBtn.center = CGPoint(x: view.center.x, y: yPosition)
        view.addSubview(recordBtn)
        
        //        let controlsView = UIStackView.init(arrangedSubviews: [recordBtn, samplesBtn])
//        controlsView.frame = CGRect(x: 0, y: yPosition, width: view.frame.width-80, height: 60)
//        controlsView.center = CGPoint(x: view.frame.width/2, y: yPosition-controlsView.frame.height/2)
//        controlsView.axis = .horizontal
//        controlsView.distribution = .fillEqually
//        controlsView.alignment = .center
//        controlsView.spacing = 60
//        view.addSubview(controlsView)
        //        controlsView.translatesAutoresizingMaskIntoConstraints = false
        //        view.addConstraint(NSLayoutConstraint(item: controlsView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        //        view.addConstraint(NSLayoutConstraint(item: controlsView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: <#T##Any?#>, attribute: <#T##NSLayoutAttribute#>, multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>))
        
    }
    
    
    //MARK: Recording and Playback

    func recordBtnDidPress(_ sender: Any) {
        
        switch recordingIsEnabled {
        case false:
            recordingIsEnabled = true // 1
        case true:
            recordingIsEnabled = false
        }
    }
    
    func playOrRecord(){  // 4
        switch recordingIsEnabled {
        case true:
            createNewSample()
        case false:
            if let index = selectedSampleIndex {
                SCAudioPlayer.shared.playBack(selectedSampleIndex: index)
                selectedSampleIndex = nil
            }
        }
    }

    //MARK: Shimmer
    
    func isRecordingEnabled(){
        switch recordingIsEnabled {
        case true:
            print("record enabled")
//            startTimer()
        //            shimmeringView.isShimmering = !shimmeringView.isShimmering
        case false:
            if recordingTimer != nil {
                recordingTimer?.invalidate()
            }
        }
    }
    
    
    private func setupShimmer(){
        
        let vv = UIView.init()
        shimmeringView = FBShimmeringView(frame: vv.frame)
        shimmeringView.contentView = vv
        view.addSubview(shimmeringView)
        shimmeringView.isShimmering = true
        //        shimmeringView.contentView = view
        //        shimmeringView.isShimmering = true
        //
        //        //Optional ShimmeringView protocal values
        //        //All values show are the defaults
        //        shimmeringView.shimmeringPauseDuration = 0.4
        //        shimmeringView.shimmeringAnimationOpacity = 0.5
        //        shimmeringView.shimmeringOpacity = 1.0
        //        shimmeringView.shimmeringSpeed = 230
        //        shimmeringView.shimmeringHighlightLength = 1.0
        //        shimmeringView.shimmeringDirection = FBShimmerDirection.right
        //
        //        //All possible directional values
        //        //FBShimmerDirection.Right,  Shimmer animation goes from left to right
        //        //FBShimmerDirection.Left,  Shimmer animation goes from right to left
        //        //FBShimmerDirection.Up,  Shimmer animation goes from below to above
        //        //FBShimmerDirection.Down,  Shimmer animation goes from above to below
        //
        //        shimmeringView.shimmeringBeginFadeDuration = 0.1
        //        shimmeringView.shimmeringEndFadeDuration = 0.3
        
    }

    func startTimer(){ // 2
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.7,
                                              repeats: true) {
                                                
                                                //"[weak self]" creates a "capture group" for timer
                                                [weak self] timer in
                                                
                                                //Add a guard statement to bail out of the timer code
                                                //if the object has been freed.
                                                guard self != nil else {
                                                    return
                                                }
                                                //Put the code that be called by the timer here.
                                                self?.changeColor()
                                                //                                        strongSelf.someOtherProperty = someValue
        }
    }
    
    
    func changeColor(){  // 3
        switch flashingOn { // Shimmer across all, one is chosen -> Shimmer on one
        case true:
            view.backgroundColor = UIColor.lightGray
            flashingOn = false
        case false:
            view.backgroundColor = UIColor.yellow
            flashingOn = true
        }
    }

    
    
    //MARK: Playback

   //    func playSample() {
//        
//        guard let url = findSampleURL() else {
//            print("playback url not found")
//            selectedBtnIndex = nil
//            return
//        }
//        AudioPlayer.sharedInstance.playSound(soundFileURL: url)
//        selectedBtnIndex = nil
//    }
//    
//    
//    
//    func findSampleURL() -> URL? {
//        
//        var selectedRecording: Sample? = nil
//        
//        for x in SampleManager.shared.samples {
//            if x.key == selectedBtnIndex {
//                selectedRecording = x
//            }
//        }
//        guard let url = selectedRecording?.url else {
//            print("no url")
//            return
//        }
//        return url
//    }
//    

  //MARK: Record
    
    func createNewSample(){ // 5
        if audioRecorder == nil {
            setupRecordingSession()
            recordingTimer?.invalidate()
        } else {
            finishRecording(success: true)
            selectedSampleIndex = nil
        }
        
    }
    
    
    
    func setupRecordingSession(){
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                        print("record successful")
                    } else {
                        print("failed to record!")
                    }
                }
            }
        } catch {
            // failed to record!
            print("failed to record!")
        }
    }
    
    
    
    func startRecording() {
        
        //            getNewRecordingTitle()
        //            if let title = newRecordingTitle {
        let title = UUID.init()
        
        audioFilename = getDocumentsDirectory().appendingPathComponent("\(title)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func finishRecording(success: Bool) {
        if audioRecorder != nil {
            
            audioRecorder.stop()
            audioRecorder = nil
            if audioFilename != nil {
                let sample = SCSample.init(key: selectedSampleIndex!, url: audioFilename!)
                print(sample.url!)
                SCSampleManager.shared.sampleBank.append(sample)
            }
            recordingIsEnabled = false // so that we set the buttons to play
        }
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    private func getNewRecordingTitle() {
        
        // add textfield to the alertController
        let alertController = UIAlertController(title: "New Recording", message: "Enter your a title...", preferredStyle: .alert)
        
        alertController.addTextField()
        
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            // test if entry is valid
            let textField = alertController.textFields![0]
            guard let nameInput = textField.text, self.isValid(nameInput:nameInput) else {
                let requiredAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                AlertManager.ShowAlert(title: "Invalid entry", message: "Name must at least one character in length.", requiredAction: requiredAction, optionalAction: nil, in: self)
                print("new recording title failed validation")
                return
            }
            self.newRecordingTitle = textField.text!
            print("User entered: \(textField.text!) for name in text field")
            
        }))
        self.present(alertController, animated: true, completion:{
        })
    }
    
    
    
    func isValid(nameInput: String) -> Bool {
        // check the name is greater than one character
        if !(1 < nameInput.characters.count) {
            return false
        }
        // check that name doesn't contain whitespace or newline characters
        if textFieldIsEmpty(input: nameInput) == true {
            return false
        }
        return true
    }
    
    
    
    func textFieldIsEmpty(input:String?) -> Bool {
        
        return (input?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!
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
        cell.layer.cornerRadius = 10
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            animateCell(cell: cell as! SCSamplerCollectionViewCell)
            selectedSampleIndex = indexPath.row
            playOrRecord()  // 4
            colorManager?.morphColors()
        }
    }
    
    func animateCell(cell: SCSamplerCollectionViewCell) {
        
        UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 0,
                       initialSpringVelocity: 50,options: [],
                       animations: {
                        cell.alpha = 0
                        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.05, delay: 0, usingSpringWithDamping: 0,
                                       initialSpringVelocity: 50, options: .curveEaseInOut,
                                       animations: {
                                        cell.alpha = 1
                                        cell.transform = CGAffineTransform(scaleX: 1, y: 1)
                        },
                                       completion: nil
                        )
        })
    }
    
    func createColorSets() {
        colorSets.append([UIColor.black.cgColor, UIColor.lightGray.cgColor, UIColor.white.cgColor, UIColor.black.cgColor])
        colorSets.append([UIColor.black.cgColor, UIColor.red.cgColor, UIColor.orange.cgColor, UIColor.magenta.cgColor, UIColor.yellow.cgColor, UIColor.black.cgColor])
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
