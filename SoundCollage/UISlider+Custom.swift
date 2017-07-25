//
//  UISlider+Custom.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit

extension UISlider {
    
    class func setupSlider() -> UISlider {
        
        //Initialize slider as 0, then update once we have the frame properties.
        let slider = UISlider(frame: .zero)
        //Rotate to a vertical slider
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
        slider.isContinuous = false
        slider.isHidden = true
        return slider
    }

    
    class func updateSlider(slider: UISlider, xPosition: CGFloat, view: UIView){
        //Update the slider, this is called after the rotation, thus it has the correct size

        let yPosition = view.frame.minY + view.frame.height * 0.1
        let width = view.frame.width * 0.1
        let height = view.frame.height * 0.5
        let sliderFrame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        slider.frame = sliderFrame
    }
    
    
    
    class func setSliderFrame(slider: UISlider, view: UIView) {
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
