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
 
    
    init(name: String, sbID: Int, samples: [String: String], effectSettings: [[SCEffectControl]] , sequencerSettings: SCSequencerSettings?) {
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
            let effectJSON = json["effectSettings"] as? [[[Float]]], // TODO: crashes occurs here
            let seqJSON = json["sequencerSettings"] as? [[Bool]]
            else {
                print("json error")
                return nil
        }
        
        let am = SCAudioManager.shared
        
        // create effect settings
        
        var effectSettings: [[SCEffectControl]] = []
        
        while effectSettings.count<Array(am.mixerPanels.keys).count{
            var controls: [SCEffectControl] = []
            while controls.count<5 {
                let ec = SCEffectControl.init()
                controls.append(ec)
            }
            effectSettings.append(controls)
        }
        
        for (index, settingsJSON) in effectJSON.enumerated().reversed() {
            
            for (idx, obj) in settingsJSON.enumerated() {
                effectSettings[index][idx].parameter = obj
            }
        }
        
        
        // create sequencer settings
        
         let sequencerSettings = SCSequencerSettings.init(score: seqJSON)
     
        
        self.init(name: name, sbID: sbID, samples: samples , effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        self.name = name
        self.sbID = sbID
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
}
