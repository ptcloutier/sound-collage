//
//  SCSequencerInnerCell.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/10/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import UIKit

class SCTriggerCell: UICollectionViewCell {
    
    var sequencerIdx: Int = 0
    var idx: Int = 0
    var isPlaybackEnabled: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  }
