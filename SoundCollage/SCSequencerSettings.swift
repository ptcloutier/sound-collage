//
//  SCSequencerSettings.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSequencerSettings {
    
    
//    enum TimeSignature {
//        case threeFour
//        case fourFour
//    }
//    
//    
//    var timeSignature = TimeSignature.fourFour
    
    var score: [[Bool]] = []
    
    init(score: [[Bool]]) {
        self.score = score
    }
    
    
    convenience init?(json: [String: Any]) {
        
        guard let score = json["score"] as? [[Bool]]
            else {
                print("json error")
                return nil
        }
        self.init(score: score)
        self.score = score
    }
}
