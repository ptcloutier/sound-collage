//
//  SCSequencerSettings.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import ObjectMapper

class SCSequencerSettings: Mappable {
    
    
    enum TimeSignature {
        case threeFour
        case fourFour
    }
    
    
    var timeSignature = TimeSignature.fourFour
   
    var score: [[Bool]] = []
    
    init(score: [[Bool]]) {
        self.score = score
    }
    
    
    required init?(map: Map) {
        timeSignature   <- map["timeSignature"]
        score           <- map["score"]
    }
    
    
    func mapping(map: Map) {
        timeSignature   <- map["timeSignature"]
        score           <- map["score"]
    }

}
