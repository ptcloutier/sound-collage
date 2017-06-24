//
//  UIButton+Custom.swift
//  SoundCollage
//
//  Created by perrin cloutier on 6/21/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    class func FlatColorStyle(height: CGFloat, primaryColor: UIColor, secondaryColor: UIColor)-> UIButton {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: height , height: height)
        let back = UIView.init(frame: btn.frame)
        back.isUserInteractionEnabled = false
        back.layer.cornerRadius = height/2
        back.layer.masksToBounds = true
        back.layer.borderWidth = 3.0
        back.backgroundColor = primaryColor
        back.layer.borderColor = secondaryColor.cgColor
        btn.addSubview(back)
        return btn
    }
   
    
    class func GradientColorStyle(height: CGFloat, gradientColors: [UIColor], secondaryColor: UIColor)-> UIButton {
        
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: height , height: height)
        let back = UIView.init(frame: btn.frame)
        back.applyGradient(withColors: gradientColors, gradientOrientation: .topLeftBottomRight)
        back.isUserInteractionEnabled = false
        back.layer.cornerRadius = height/2
        back.layer.masksToBounds = true
        back.layer.borderWidth = 3.0
        back.layer.borderColor = secondaryColor.cgColor 
        btn.addSubview(back)
        return btn
    }

}
