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
    var selectedCellLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupNameLabel() {
        
        nameLabel.font = UIFont.init(name: "Quicksand_light", size: 20.0)
        nameLabel.textColor = SCColor.Custom.PsychedelicIceCreamShoppe.ice
        nameLabel.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0))
    }
    
    
    func setupSelectedCellLabel(number: Int){
       
        selectedCellLabel.text = "\(number)"
        selectedCellLabel.font = UIFont.init(name: "Quicksand_light", size: 30)
        selectedCellLabel.textColor = SCColor.Custom.PsychedelicIceCreamShoppe.ice
        self.contentView.addSubview(selectedCellLabel)
        selectedCellLabel.translatesAutoresizingMaskIntoConstraints = false 
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedCellLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 30.0))
        self.contentView.addConstraint(NSLayoutConstraint(item: selectedCellLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0))
        

    }
    
    
    //MARK: UISlider
  
    
    func setupSlider(slider: SCSlider){
        
        let frame = slider.trackRect(forBounds: self.contentView.frame)
        slider.frame = frame
        // make vertical
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        slider.isContinuous = false
        addSliderTarget(slider: slider)
        slider.minimumTrackTintColor = SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral
        slider.maximumTrackTintColor = UIColor.white
        let image = UIImage.imageWithImage(image: UIImage.init(named: "rectPink")!, newSize: CGSize(width: 20.0, height: 50.0))
        slider.setThumbImage(image, for: .normal)
        self.contentView.addSubview(slider)
    }
    
    
   
    
    
    
    func setupParameterLabel(parameterLabel: UILabel, slider: SCSlider, name: String){
        
        parameterLabel.frame = CGRect(x: slider.frame.origin.x, y: slider.frame.origin.y, width: 100.0, height: 20.0)
        parameterLabel.text = name
        parameterLabel.textColor = SCColor.Custom.PsychedelicIceCreamShoppe.ice
        parameterLabel.font = UIFont.init(name: "Quicksand_Light", size: 12.0)
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
            self.slider1.frame.origin.x = (contentView.frame.width/6)*2.5
            self.slider2.frame.origin.x = (contentView.frame.width/6)*3.5
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
            self.slider1.frame.origin.x = (contentView.frame.width/6)*2
            self.slider2.frame.origin.x = (contentView.frame.width/6)*3
            self.slider3.frame.origin.x = (contentView.frame.width/6)*4
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
            self.slider1.frame.origin.x = (contentView.frame.width/6)*1.5
            self.slider2.frame.origin.x = (contentView.frame.width/6)*2.5
            self.slider3.frame.origin.x = (contentView.frame.width/6)*3.5
            self.slider4.frame.origin.x = (contentView.frame.width/6)*4.5
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
            self.slider1.frame.origin.x = (contentView.frame.width/6)
            self.slider2.frame.origin.x = (contentView.frame.width/6)*2
            self.slider3.frame.origin.x = (contentView.frame.width/6)*3
            self.slider4.frame.origin.x = (contentView.frame.width/6)*4
            self.slider5.frame.origin.x = (contentView.frame.width/6)*5
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
//        for (index, l) in parameterLabels.enumerated() {
//            let width: CGFloat = 0
//            setupLabelAutoLayout(parameterLabel: l, slider: sliders[index], labelWidth: width)
//            
//        }
    }

    

    func addSliderTarget(slider: SCSlider){
        slider.addTarget(self, action: #selector(SCMixerPanelCell.sliderChanged(sender:)), for: .valueChanged)
    }
    
    
    func sliderChanged(sender: SCSlider) {
        
        //Use the value from the slider for something
        // When slider changes, alert the controller, the controller will get the selected effect, the index of the slider will be the parameter to change and slider value will be the value 
        
    }
    
//    
//    func setupLabelAutoLayout(parameterLabel: UILabel, slider: SCSlider, labelWidth: CGFloat){
//        parameterLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        self.contentView.addConstraint(NSLayoutConstraint(item: parameterLabel, attribute: .leading, relatedBy: .equal, toItem: slider, attribute: .leading, multiplier: 1.0, constant: 0))
//        self.contentView.addConstraint(NSLayoutConstraint(item: parameterLabel, attribute: .bottom, relatedBy: .equal, toItem: slider, attribute: .bottom, multiplier: 1.0, constant: 0))
//    }
//    
    
    
    
    
    func verticalLabel(label: UILabel){
        
        label.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))

    }
    
    
    func adjustLabel(label: UILabel, slider: SCSlider){
        
        label.frame.origin.x = slider.frame.origin.x-40.0
        label.frame.origin.y = slider.frame.minY 
    }

    
}
