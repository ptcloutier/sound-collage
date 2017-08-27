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
        let esJSON = json["effectSettings"] as? ,
            let sequencerSettings = json["sequencerSettings"] as? SCSequencerSettings?
            else {
                print("json error")
                return nil
        }
        
        
        // create effect settings
        
        var effectSettings: [[SCEffectControl]] = []
        
        while effectSettings.count<Array(SCAudioManager.shared.mixerPanels.keys).count{
            var controls: [SCEffectControl] = []
            while controls.count<5{
                let ec = SCEffectControl.init()
                controls.append(ec)
            }
            effectSettings.append(controls)
        }

        for (index, settings) in esJSON.enumerated() {
            

            for (idx, ec) in settings.enumerated() {
                effectSettings[index][idx].parameter = ec.parameter
            }
        }
        
        
        
        

        
        
        
        self.init(name: name, sbID: sbID, samples: samples , effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        self.name = name
        self.sbID = sbID
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
}
