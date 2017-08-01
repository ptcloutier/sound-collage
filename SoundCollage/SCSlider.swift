//
//  SCSlider.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCSlider: UISlider {
    
    var idx: Int = 0
    var trackHeight: CGFloat = 2
    var xPos: CGFloat = 0
    
  
    
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {

        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
    }
    
    
    
    func updateSlider(slider: SCSlider, view: UIView){
        
        let yPosition = (view.frame.minY + view.frame.height * 0.3)
        let width = view.frame.width * 0.1
        let height = view.frame.height * 0.5
        let sliderFrame = CGRect(x: self.xPos, y: yPosition, width: width, height: height)
        slider.frame = sliderFrame
    }
    
    
    
    func setSliderFrame(slider: SCSlider, view: UIView) {
        
        let xPos = view.frame.maxX - view.frame.width * 0.1
        let yPos = view.frame.minY + view.frame.height * 0.1
        let width = view.frame.width * 0.1
        let height = view.frame.height * 0.8
        let sliderFrame = CGRect(x: xPos, y: yPos, width: width, height: height)
        slider.frame = sliderFrame
        slider.isHidden = false
    }
    
    
    
}
