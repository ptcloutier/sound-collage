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
 
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        var xPosition = 30.0
        
        for (index, slider) in sliders.enumerated() {
            slider.updateSlider(slider: slider, xPosition: CGFloat(xPosition), view: self.contentView)
            xPosition+=35.0
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
    

    
    
}
