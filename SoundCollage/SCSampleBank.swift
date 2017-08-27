//
//  SCSampleBank.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation



class SCSampleBank {
    
    var name: String = ""
    var sbID: Int = 0
    var samples: [String: String] = [:]
    var effectSettings: [[SCEffectControl]] = []
    var sequencerSettings: SCSequencerSettings?
 
    
    init(name: String, sbID: Int, samples: [String: String], effectSettings: [[SCEffectControl]] , sequencerSettings: SCSequencerSettings? ) {
        self.name = name
        self.sbID = sbID
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }

    
    convenience init?(json: [String: Any]) {
        
        guard let name = json["name"] as? String,
            let sbID = json["sbID"] as? Int,
            let samples = json["samples"] as? [String: String],
            let effectSettings = json["effectSettings"] as? [[SCEffectControl]],
            let sequencerSettings = json["sequencerSettings"] as? SCSequencerSettings?
            else {
                print("json error")
                return nil
        }
        self.init(name: name, sbID: sbID, samples: samples , effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        self.name = name
        self.sbID = sbID
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
}
