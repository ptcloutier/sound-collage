//
//  SCMixerPanelCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/26/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCMixerPanelCell: UICollectionViewCell {
    
    var mixerPanelIdx: Int?
    var sliders: [SCSlider] = []
    var nameLabel = UILabel()
 
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupNameLabel(name: String, textColor: UIColor) {
        
        nameLabel.text = name
        nameLabel.font = UIFont.init(name: "Futura", size: 20.0)
        nameLabel.textColor = textColor
        nameLabel.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0))
//        self.contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: ., multiplier: <#T##CGFloat#>, constant: <#T##CGFloat#>)
    }
    
    //MARK: UISlider
    
    
    
    
    func initializeSliders(){
        
        while sliders.count < 5 {
            let slider = SCSlider.init(frame: .zero)
            let frame = slider.trackRect(forBounds: self.contentView.frame)
            slider.frame = frame
            // make vertical
            slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
            slider.isContinuous = false
            slider.isHidden = true
            sliders.append(slider)
        }
    }
    
    
    func setupSliders(){
        
        for slider in sliders {
            addSliderTarget(slider: slider)
            slider.minimumTrackTintColor = SCColor.Custom.PsychedelicIceCreamShoppe.brightCoral
            slider.maximumTrackTintColor = SCColor.Custom.PsychedelicIceCreamShoppe.lightViolet
            let image = UIImage.imageWithImage(image: UIImage.init(named: "rectPink")!, newSize: CGSize(width: 10.0, height: 30.0))
            slider.setThumbImage(image, for: .normal)
        }
    }
    
    
    
    func slidersWillAppear() {
        
        for slider in sliders {
            slider.isHidden = false
            self.contentView.addSubview(slider)
            
        }
    }
    
    
    func viewWillLayoutSliders() {
        
        let result: (CGFloat, CGFloat) = getSliderXPositionAndOffset()
        var xPosition = result.0
        let offset = result.1
        
        for (index, slider) in sliders.enumerated() {
            slider.updateSlider(slider: slider, xPosition: xPosition, view: self.contentView)
            xPosition+=offset
            slider.idx = index
        }
    }
    
    

    func addSliderTarget(slider: SCSlider){
        slider.addTarget(self, action: #selector(SCMixerPanelCell.sliderChanged(sender:)), for: .valueChanged)
    }
    
    
    func sliderChanged(sender: SCSlider) {
        
        //Use the value from the slider for something
        // When slider changes, alert the controller, the controller will get the selected effect, the index of the slider will be the parameter to change and slider value will be the value 
        
    }
    
    
    
    func getSliderXPositionAndOffset()-> (CGFloat, CGFloat){
        
        let vals = Array(SCAudioManager.shared.mixerPanels.values)
        
        var xPos: CGFloat
        var offset: CGFloat
        
        switch vals[self.mixerPanelIdx!].count  {
    
        case 1 :
            print("1 slider")
            xPos = self.center.x
            offset = 0
        case 2 :
            print("2 sliders")
            xPos = self.center.x - self.contentView.frame.width/6
            offset = (self.contentView.frame.width/6)*2
        case 3 :
            print("3 sliders")
            xPos = self.contentView.frame.width/8
            offset = self.contentView.frame.width/4
        case 4 :
            print("4 sliders")
            xPos = self.contentView.frame.width/10
            offset = self.contentView.frame.width/5
        case 5 :
            print("5 sliders")
            xPos = self.contentView.frame.width/12
            offset = self.contentView.frame.width/6
        default :
            print("Default default default")
            xPos = 0
            offset = 0
        }
        return (xPos, offset)
    }

    
    
}
