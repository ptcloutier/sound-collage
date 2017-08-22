//
//  SCToolbar.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/22/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCToolbar: UIToolbar {
    
    
    func transparentToolbar(view: UIView, toolbarHeight: CGFloat) {
    
        let transparentPixel = UIImage.imageWithColor(color: UIColor.clear)
        self.frame = CGRect(x: 0, y: view.frame.height-toolbarHeight, width: view.frame.width, height: toolbarHeight)
        self.setBackgroundImage(transparentPixel, forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(transparentPixel, forToolbarPosition: .any)
        self.isTranslucent = true
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
