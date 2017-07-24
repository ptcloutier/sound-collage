//
//  SCSequencerSettings.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSequencerSettings {
    
    var timeSignature = TimeSignature.fourFour
    
    enum TimeSignature {
        case threeFour
        case fourFour
    }
    var score: [[Bool]] = []
    
    init(score: [[Bool]]) {
        self.score = score
    }
}
