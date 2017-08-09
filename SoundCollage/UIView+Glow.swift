//
//  UIView+Glow.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/8/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addGlow(color: UIColor){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = .zero
        self.layer.masksToBounds = false
    }
}
