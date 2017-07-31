//
//  SCCircularView.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/30/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCCircularImageView: UIImageView {

        override func layoutSubviews() {
            super.layoutSubviews()
            
            let radius: CGFloat = self.bounds.size.width / 2.0
            
            self.layer.cornerRadius = radius
        }
    }

