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
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        //set your bounds here
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
        
    }
    
    
    
    func updateSlider(slider: SCSlider, xPosition: CGFloat, view: UIView){
        //Update the slider, this is called after the rotation, thus it has the correct size
        
        let yPosition = (view.frame.minY + view.frame.height * 0.3)
        let width = view.frame.width * 0.1
        let height = view.frame.height * 0.3
        let sliderFrame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        slider.frame = sliderFrame
    }
    
    
    
    func setSliderFrame(slider: SCSlider, view: UIView) {
        //Now that we have a frame, set the slider frame
        
        let xPos = view.frame.maxX - view.frame.width * 0.1
        let yPos = view.frame.minY + view.frame.height * 0.1
        let width = view.frame.width * 0.1
        let height = view.frame.height * 0.8
        let sliderFrame = CGRect(x: xPos, y: yPos, width: width, height: height)
        slider.frame = sliderFrame
        slider.isHidden = false
    }
}
