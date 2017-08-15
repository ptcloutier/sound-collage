//
//  SCSampleBank.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import ObjectMapper

class SCSampleBank: Mappable {
   
    var name: String?
    var id: Int?
    var samples: [String: AnyObject]?
    var effectSettings: [[SCEffectControl]]?
    var sequencerSettings: SCSequencerSettings?
    
    
    init(name: String?, id: Int?, samples: [String: AnyObject]?, effectSettings: [[SCEffectControl]]? , sequencerSettings: SCSequencerSettings? ) {
        self.name = name
        self.id = id
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
    
    required init?(map: Map) {
//        name                <- map["name"]
//        id                  <- map["id"]
//        samples             <- map["samples"]
//        effectSettings      <- map["effectSettings"]
//        sequencerSettings   <- map["sequencerSettings"]
    }
    
    func mapping(map: Map) {
        name                <- map["name"]
        id                  <- map["id"]
        samples             <- map["samples"]
        effectSettings      <- map["effectSettings"]
        sequencerSettings   <- map["sequencerSettings"]
    }
}
