//
//  SCSequencerSettings.swift
//  SoundCollage
//
//  Created by perrin cloutier on 7/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSequencerSettings {
    
    
    enum TimeSignature {
        case threeFour
        case fourFour
    }
    
    
    var timeSignature = TimeSignature.fourFour
    
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

//import ObjectMapper
//
//class SCSequencerSettings: Mappable {
//    
//    
//    enum TimeSignature {
//        case threeFour
//        case fourFour
//    }
//    
//    
//    var timeSignature = TimeSignature.fourFour
//   
//    var score: [[Bool]] = []
//    
//    init(score: [[Bool]]) {
//        self.score = score
//    }
//    
//    
//    required init?(map: Map) {
//        // check if a required property exists within the JSON.
//        if map.JSON["timeSignature"] == nil {
//            print("Json error, scseqsettings time sig is nil")
//            return nil
//        }
//        if map.JSON["score"] == nil {
//            print("Json error, scseqsettings score is nil")
//            return nil
//        }
//    }
//    
//    
//    func mapping(map: Map) {
//        timeSignature   <- map["timeSignature"]
//        score           <- map["score"]
//    }
//
//}
