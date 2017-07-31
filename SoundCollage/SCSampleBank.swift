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
    
    var samples: [String: AnyObject] = [:]
    var name: String? 
    var id: Int?
    var type: SamplerType?
    var effectSettings: [[SCEffectControl]] = []
    var sequencerSettings: SCSequencerSettings?
    
    
    init(name: String?, id: Int?, samples: [String: AnyObject], type: SamplerType?, effectSettings: [[SCEffectControl]] , sequencerSettings: SCSequencerSettings? ) {
        self.name = name
        self.id = id
        self.samples = samples
        self.type = type
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
    
    required init?(map: Map) {
        samples     <- map["samples"]
        name        <- map["name"]
        id          <- map["id"]
        type        <- map["type"]
        effectSettings  <- map["effectSettings"]
        sequencerSettings   <- map["sequencerSettings"]
    }
    
    func mapping(map: Map) {
        samples     <- map["samples"]
        name        <- map["name"]
        id          <- map["id"]
        type        <- map["type"]
        effectSettings  <- map["effectSettings"]
        sequencerSettings   <- map["sequencerSettings"]
    }
    
    enum SamplerType {
        case standard
        case double
    }

}
