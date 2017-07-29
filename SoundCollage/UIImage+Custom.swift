//
//  UIImage+resize.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    class func imageWithImage(image: UIImage, newSize: CGSize)-> UIImage {
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func imageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    
    
    
}
