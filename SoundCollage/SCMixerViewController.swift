//
//  SCMixerViewController.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCMixerViewController: UIViewController {
    
    var parameterView: UIView?
    var mixerCV: UICollectionView?
    var effects: [String] = []
    let toolbarHeight: CGFloat = 125.0
    var sliders: [UISlider] = []
    
    
    
    //MARK: VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMixerCV()
        setupParameterView()
        initializeSliders()
        setupSliders()
        NotificationCenter.default.addObserver(self, selector: #selector(SCMixerViewController.selectedSamplePadDidChange), name: Notification.Name.init("selectedSamplePadDidChangeNotification"), object: nil)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        for slider in sliders {
            UISlider.setSliderFrame(slider: slider, view: view)
            if self.parameterView != nil {
                self.parameterView?.addSubview(slider)
            }
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        
        var xPosition = 20.0
        
        for (index, slider) in sliders.enumerated() {
            UISlider.updateSlider(slider: slider, xPosition: CGFloat(xPosition), view: view)
            xPosition+=35.0
            print("\(index)")
        }
    }
    
    
    
    //MARK: UISlider
    
    
    
    
    func initializeSliders(){
        
        while sliders.count < 8  {
            let slider = UISlider.setupSlider()
            sliders.append(slider)
        }
    }
    
    
    func setupSliders(){
        
        for slider in sliders {
            addSliderTarget(slider: slider)
            slider.minimumTrackTintColor = UIColor.Custom.PsychedelicIceCreamShoppe.brightCoral
            slider.maximumTrackTintColor = UIColor.Custom.PsychedelicIceCreamShoppe.lightViolet
            let image = UIImage.imageWithImage(image: UIImage.init(named: "rectPink")!, newSize: CGSize(width: 10.0, height: 30.0))
            slider.setThumbImage(image, for: .normal)
        }
    }
    
    
    func addSliderTarget(slider: UISlider){
        slider.addTarget(self, action: #selector(SCEffectsViewController.sliderChanged(sender:)), for: .valueChanged)
    }
    
    
    func sliderChanged(sender: UISlider) {
        //Use the value from the slider for something
        print("sup")
    }
    
    
    //MARK: left-hand vertical collection view
    
    func setupMixerCV(){
        
        let mixerFlowLayout = SCSamplerFlowLayout.init(direction: .horizontal, numberOfColumns: 1)
        self.mixerCV = UICollectionView.init(frame: .zero, collectionViewLayout: mixerFlowLayout)
        guard let mixerCV = self.mixerCV else {
            print("No effects container.")
            return
        }
        mixerCV.isPagingEnabled = true
        mixerCV.allowsMultipleSelection = true
        mixerCV.delegate = self
        mixerCV.dataSource = self
        mixerCV.isScrollEnabled = false 
        // selected cell number, a cv you can scroll
        mixerCV.register(SCPadNumberCell.self, forCellWithReuseIdentifier: "PadNumberCell")
        // sequencer tempo, a cv you can scroll
        // a visual metronome
        mixerCV.backgroundColor = UIColor.clear
        self.view.addSubview(mixerCV)
        
        mixerCV.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: mixerCV, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.1, constant: 0))
    }
    
    
    //MARK: main mixer sliders
    
    func setupParameterView(){
        
        parameterView = UIView.init(frame: .zero)
        guard let parameterView = self.parameterView else {
            print("No parameter view.")
            return
        }
        
        parameterView.isUserInteractionEnabled = true
        parameterView.isMultipleTouchEnabled = false
        parameterView.layer.masksToBounds = true
        parameterView.layer.cornerRadius = 15.0
        parameterView.layer.borderWidth = 3
        parameterView.layer.borderColor = UIColor.purple.cgColor
        parameterView.backgroundColor = UIColor.Custom.VintageSeaStyle.brightVintageRed
        self.view.addSubview(parameterView)
        
        parameterView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .top, relatedBy: .equal, toItem: self.mixerCV, attribute: .bottom, multiplier: 1.0, constant: 10.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: parameterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -toolbarHeight))
    }
    
    
    
    
    
    //MARK: effects parameter //TODO: update to slider values
    
    func handleParameterGesture(gestureRecognizer: UIGestureRecognizer){
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            let location =  gestureRecognizer.location(in: parameterView)
            
            let sampleIndex = SCAudioManager.shared.selectedSampleIndex
            SCAudioManager.shared.handleEffectsParameters(point: location, sampleIndex: sampleIndex)
        }
    }
    
    
    //MARK: selected sample pad 
    
    func selectedSamplePadDidChange(){
        self.mixerCV?.reloadData()
    }
}




extension SCMixerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let mixerCellSize = CGSize.init(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
        return mixerCellSize
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.row == 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PadNumberCell", for: indexPath) as! SCPadNumberCell
        cell.colors = SCGradientColors.getPsychedelicIceCreamShopColors()
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = collectionView.frame.size.height/2
        cell.contentView.backgroundColor = cell.colors[indexPath.row]
        cell.setupLabel(title: "\(SCAudioManager.shared.selectedSampleIndex+1)")
        return cell
//        } else {
//            
//        }
        
    }
}
