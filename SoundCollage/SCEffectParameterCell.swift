//
//  SCEffectParameterCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 5/27/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCEffectParameterCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.init(red: 255.0, green: 0, blue: 128.0, alpha: 1.0)

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
