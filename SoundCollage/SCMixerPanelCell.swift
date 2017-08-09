//
//  SCMixerPanelCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/26/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCMixerPanelCell: UICollectionViewCell {
    
    var mixerPanelIdx: Int = 0
    var sliders: [SCSlider] = []
    var nameLabel = UILabel()
    var slider1 = SCSlider()
    var slider2 = SCSlider()
    var slider3 = SCSlider()
    var slider4 = SCSlider()
    var slider5 = SCSlider()
    var pLabel1 = UILabel()
    var pLabel2 = UILabel()
    var pLabel3 = UILabel()
    var pLabel4 = UILabel()
    var pLabel5 = UILabel()
    var parameterLabels: [UILabel] = []
    var sliderXPositions: [CGFloat] = []
    var selectedPadTextLabel = UILabel()
    var selectedPadNumberLabel = UILabel()
    var selectedPadCircle = SCCircularImageView()
    weak var faderDelegate: SCFaderDelegate?
    var color: UIColor = UIColor.white
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func setupFaderDelegate(delegate: SCFaderDelegate){
        
        self.faderDelegate = delegate
    }
    
    
    
    
    
    //MARK: Labels
   
    
    
    
    
    func setupNameLabel() {
        
        nameLabel.textColor = color
        nameLabel.addGlow(color: color)
        nameLabel.font = UIFont.init(name: "Futura", size: 30.0)
        nameLabel.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0))
    }
    
    
    
    
    func setupSelectedCellLabel(number: Int){
        
        selectedPadTextLabel.addGlow(color: color)//UIColor.white)
        selectedPadTextLabel.text = "Selected"
        selectedPadTextLabel.font = UIFont.init(name: "Futura", size: 12)
        selectedPadTextLabel.textColor = color//UIColor.white//SCColor.Custom.PsychedelicIceCreamShoppe.deepBlue
        self.contentView.addSubview(selectedPadTextLabel)
        selectedPadTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        selectedPadNumberLabel.addGlow(color: color)
        selectedPadNumberLabel.text = "\(number+1)"
        selectedPadNumberLabel.font = UIFont.init(name: "Futura", size: 25)
        selectedPadNumberLabel.textColor = color//UIColor.white// SCColor.Custom.PsychedelicIceCreamShoppe.deepBlue
        self.contentView.addSubview(selectedPadNumberLabel)
        selectedPadNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        selectedPadCircle.addGlow(color: color)//UIColor.white)
        selectedPadCircle.layer.borderWidth = 1.0
        selectedPadCircle.layer.borderColor = color.cgColor//UIColor.white.cgColor
        selectedPadCircle.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(selectedPadCircle)
        
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadNumberLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -50.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadNumberLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 30.0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadTextLabel, attribute: .centerX, relatedBy: .equal, toItem: selectedPadNumberLabel, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadTextLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 20.0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadCircle, attribute: .width, relatedBy: .equal, toItem: self.selectedPadTextLabel, attribute: .width,  multiplier: 1.4, constant: 0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadCircle, attribute: .height, relatedBy: .equal, toItem: selectedPadCircle, attribute: .width,  multiplier: 1.0, constant: 0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedPadCircle, attribute: NSLayoutAttribute.centerX, relatedBy: .equal, toItem: self.selectedPadNumberLabel, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        
        
//        
//        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SCSamplerViewController.tap(gestureRecognizer:)))
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
//        tapGestureRecognizer.delegate = self
//        selectedPadTextLabel.addGestureRecognizer(tapGestureRecognizer)
//        selectedPadNumberLabel.addGestureRecognizer(tapGestureRecognizer)
//        selectedPadCircle.addGestureRecognizer(tapGestureRecognizer)

    }
    

    
    func setupParameterLabel(parameterLabel: UILabel, slider: SCSlider, name: String){
        
        parameterLabel.frame = CGRect(x: slider.frame.origin.x, y: slider.frame.origin.y, width: 100.0, height: 20.0)
        parameterLabel.text = name
        parameterLabel.textColor = color//UIColor.white//SCColor.Custom.PsychedelicIceCreamShoppe.deepBlueShade
        parameterLabel.font = UIFont.init(name: "Futura", size: 17.0)
        parameterLabel.textAlignment = NSTextAlignment.left
        parameterLabel.sizeToFit()
        self.contentView.addSubview(parameterLabel)
        
    }
   
    
    
    
    
    func showSlidersAndLabels() { //TODO: DRY
      
        var vals = Array(SCAudioManager.shared.mixerPanels.values)
        
        for (index, v) in vals[self.mixerPanelIdx].enumerated().reversed() {
            if v == "" {
                vals[self.mixerPanelIdx].remove(at: index)
            }
        }
        
        switch vals[self.mixerPanelIdx].count  {
        
            
        case 1:
            self.slider1.isHidden = false
            self.slider2.isHidden = true
            self.slider3.isHidden = true
            self.slider4.isHidden = true
            self.slider5.isHidden = true
            self.slider1.frame.origin.x = (contentView.frame.width/6)*3
            self.slider1.xPos = self.slider1.frame.origin.x
          
            pLabel1.isHidden = false
            pLabel2.isHidden = true
            pLabel3.isHidden = true
            pLabel4.isHidden = true
            pLabel5.isHidden = true
            
            
           

        case 2:
            self.slider1.isHidden = false
            self.slider2.isHidden = false
            self.slider3.isHidden = true
            self.slider4.isHidden = true
            self.slider5.isHidden = true
            self.slider1.frame.origin.x = (contentView.frame.width/12)*4.0
            self.slider2.frame.origin.x = (contentView.frame.width/12)*8.0
            self.slider1.xPos = self.slider1.frame.origin.x
            self.slider2.xPos = self.slider2.frame.origin.x
           
            pLabel1.isHidden = false
            pLabel2.isHidden = false
            pLabel3.isHidden = true
            pLabel4.isHidden = true
            pLabel5.isHidden = true
            pLabel1.frame.origin.x = slider1.xPos
            pLabel2.frame.origin.x = slider2.xPos
            
        case 3:
            self.slider1.isHidden = false
            self.slider2.isHidden = false
            self.slider3.isHidden = false
            self.slider4.isHidden = true
            self.slider5.isHidden = true
            self.slider1.frame.origin.x = (contentView.frame.width/12)*2.5
            self.slider2.frame.origin.x = (contentView.frame.width/12)*6.0
            self.slider3.frame.origin.x = (contentView.frame.width/12)*9.5
            self.slider1.xPos = self.slider1.frame.origin.x
            self.slider2.xPos = self.slider2.frame.origin.x
            self.slider3.xPos = self.slider3.frame.origin.x
            pLabel1.isHidden = false
            pLabel2.isHidden = false
            pLabel3.isHidden = false
            pLabel4.isHidden = true
            pLabel5.isHidden = true
            pLabel1.center.x = slider1.xPos
            pLabel2.center.x = slider2.xPos
            pLabel3.center.x = slider3.xPos
        case 4:
            self.slider1.isHidden = false
            self.slider2.isHidden = false
            self.slider3.isHidden = false
            self.slider4.isHidden = false
            self.slider5.isHidden = true
            self.slider1.frame.origin.x = (contentView.frame.width/12)*2.0
            self.slider2.frame.origin.x = (contentView.frame.width/12)*4.75
            self.slider3.frame.origin.x = (contentView.frame.width/12)*7.50
            self.slider4.frame.origin.x = (contentView.frame.width/12)*10.25
            self.slider1.xPos = self.slider1.frame.origin.x
            self.slider2.xPos = self.slider2.frame.origin.x
            self.slider3.xPos = self.slider3.frame.origin.x
            self.slider4.xPos = self.slider4.frame.origin.x
            pLabel1.isHidden = false
            pLabel2.isHidden = false
            pLabel3.isHidden = false
            pLabel4.isHidden = false
            pLabel5.isHidden = true
            pLabel1.center.x = slider1.xPos
            pLabel2.center.x = slider2.xPos
            pLabel3.center.x = slider3.xPos
            pLabel4.center.x = slider4.xPos
        default:
            print("default 5 sliders shown")
            self.slider1.isHidden = false
            self.slider2.isHidden = false
            self.slider3.isHidden = false
            self.slider4.isHidden = false
            self.slider5.isHidden = false
            self.slider1.frame.origin.x = (contentView.frame.width/12)*1.75
            self.slider2.frame.origin.x = (contentView.frame.width/12)*4.0
            self.slider3.frame.origin.x = (contentView.frame.width/12)*6.25
            self.slider4.frame.origin.x = (contentView.frame.width/12)*8.5
            self.slider5.frame.origin.x = (contentView.frame.width/12)*10.75
            self.slider1.xPos = self.slider1.frame.origin.x
            self.slider2.xPos = self.slider2.frame.origin.x
            self.slider3.xPos = self.slider3.frame.origin.x
            self.slider4.xPos = self.slider4.frame.origin.x
            self.slider5.xPos = self.slider5.frame.origin.x
            pLabel1.isHidden = false
            pLabel2.isHidden = false
            pLabel3.isHidden = false
            pLabel4.isHidden = false
            pLabel5.isHidden = false
            
            pLabel1.center.x = slider1.xPos
            pLabel2.center.x = slider2.xPos
            pLabel3.center.x = slider3.xPos
            pLabel4.center.x = slider4.xPos
            pLabel5.center.x = slider5.xPos
        }

    }

    
    
    
    func verticalLabel(label: UILabel) {
        
        label.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        
    }
    
    
    
    
    func adjustLabel(label: UILabel, slider: SCSlider) {
        
        label.frame.origin.x = slider.frame.origin.x-45.0
        label.frame.origin.y = slider.frame.minY
    }

    
    
    
    
    //MARK: UISlider
    
    
    func setupSlider(slider: SCSlider){
        
        let frame = slider.trackRect(forBounds: self.contentView.frame)
        slider.frame = frame
        // make vertical
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        slider.isContinuous = false
        addSliderTarget(slider: slider)
        slider.minimumTrackTintColor = color//SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral
        slider.maximumTrackTintColor = color
        slider.thumbTintColor = color
//        let image = UIImage.imageWithImage(image: UIImage.init(named: "rectWhite")!, newSize: CGSize(width: 40.0, height: 70.0))
//        slider.setThumbImage(image, for: .normal)
        self.contentView.addSubview(slider)
    }
    


    func addSliderTarget(slider: SCSlider){
        slider.addTarget(self, action: #selector(SCMixerPanelCell.sliderChanged(sender:)), for: .valueChanged)
    }
    
    
    
    
    
    func sliderChanged(sender: SCSlider) {
        
        //Use the value from the slider for something
        // When slider changes, alert the controller, the controller will get the selected effect, the index of the slider will be the parameter to change and slider value will be the value 
       
        var values: [Int] = []
        values.append(self.mixerPanelIdx)
        values.append(sender.idx)
        values.append(SCAudioManager.shared.selectedSampleIndex)
        SCAudioManager.shared.effectsParametersDidChange(values: values, sliderValue: sender.value)
        
        self.faderDelegate?.faderValueDidChange(sender: sender)
    }
    
    
    
    
}

//
//extension SCSamplerViewController: UIGestureRecognizerDelegate {
//    
//    
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//    
//    
//    
//    func tap(gestureRecognizer: UIGestureRecognizer) {
//        
//        if SCAudioManager.shared.isRecording == true {
//            print("Recording in progress")
//            return
//        }
//        
//        
//        let tapLocation = gestureRecognizer.location(in: self.samplerCV)
//        
//        guard let indexPath = self.samplerCV?.indexPathForItem(at: tapLocation) else {
//            print("IndexPath not found.")
//            return
//        }
//        
//        guard let cell = self.samplerCV?.cellForItem(at: indexPath) else {
//            print("Cell not found.")
//            return
//        }
//        
//        selectCell(cell: cell, indexPath: indexPath)
//    }
//    
//    
//    
//    func selectCell(cell: UICollectionViewCell, indexPath: IndexPath) {
//        
//        print("selected cell at \(indexPath.row)")
//        if SCAudioManager.shared.isRecordingModeEnabled == true {
//            self.selectedPadIndex = indexPath.row
//        }
//        self.collectionView(samplerCV!, didSelectItemAt: indexPath)
//    }
//}



