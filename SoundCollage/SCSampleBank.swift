//
//  SCSampleBank.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation



class SCSampleBank {
    
    var name: String?
    var samples: [String: String] = [:]
    var effectSettings: [[SCEffectControl]]?
    var sequencerSettings: SCSequencerSettings?
    
//    var jsonRepresentation : String {
//        
//        let jsonDict = ["name" : name as Any,
//                        "id" : id as Any,
//                        "samples" : samples as Any,
//                        "effectSettings" : effectSettings as Any,
//                        "sequencerSettings" : sequencerSettings as Any
//            ] as [String : Any]
//        if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
//            let jsonString = String(data:data, encoding:.utf8) {
//            return jsonString
//        } else { return "" }
//    }
    
    
    init(name: String?, samples: [String: String], effectSettings: [[SCEffectControl]]? , sequencerSettings: SCSequencerSettings? ) {
        self.name = name
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }

    
    convenience init?(json: [String: Any]) {
        
        guard let name = json["name"] as? String?,
            let samples = json["samples"] as? [String: String],
            let effectSettings = json["effectSettings"] as? [[SCEffectControl]]?,
            let sequencerSettings = json["sequencerSettings"] as? SCSequencerSettings?
            else {
                print("json error")
                return nil
        }
        
//        for k in json.keys {
//            print("\(k)")
//        }
//        for i in json.values {
//            print("\(i)")
//        }
//    
//        
//        
//        guard let name = json["name"] as? String?
//            else {
//                print("json error")
//                return nil
//        }
//        
//        guard let samplesStr = json["samples"] as? String else {
//            print("json samples failed")
//            return nil
//        }
//
//        var samples: [String: String] = [:]
//        var samplesArr = samplesStr.components(separatedBy: "\"")
//        
//        for (idx, obj) in samplesArr.enumerated().reversed() {
//            if idx % 2 == 0 {
//                samplesArr.remove(at: idx)
//                print("removing \(obj)")
//            }
//        }
//        for (idx, obj) in samplesArr.enumerated().reversed() {
//            if obj != samplesArr.last {
//                
//                if idx % 2 == 0 {
//                    let key = samplesArr[idx]
//                    let val = samplesArr[idx+1]
//                    samples[key] = val
//                }
//            }
//        }
//
//        
//        guard let effectSettings = json["effectSettings"]  else {
//            print("json effectsettings failed")
//            return nil
//        }
//        guard let sequencerSettings = json["sequencerSettings"] else {
//           print("json sequencer settings failed")
//            return nil
//        }

        
        self.init(name: name, samples: samples , effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        self.name = name
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
}
//import ObjectMapper
//
//class SCSampleBank: Mappable {
//   
//    var name: String?
//    var id: Int?
//    var samples: [String: AnyObject]?
//    var effectSettings: [[SCEffectControl]]?
//    var sequencerSettings: SCSequencerSettings?
//    
//    
//    init(name: String?, id: Int?, samples: [String: AnyObject]?, effectSettings: [[SCEffectControl]]? , sequencerSettings: SCSequencerSettings? ) {
//        self.name = name
//        self.id = id
//        self.samples = samples
//        self.effectSettings = effectSettings
//        self.sequencerSettings = sequencerSettings
//    }
//    
//    required init?(map: Map) {
//        // check if a required property exists within the JSON.
//        if map.JSON["name"] == nil {
//            print("Json error, sb name is nil")
//            return nil
//        }
//        if map.JSON["id"] == nil {
//            print("Json error, sbid is nil")
//            return nil
//        }
//        if map.JSON["samples"] == nil {
//            print("Json error, sb samples are nil")
//            return nil
//        }
//        if map.JSON["effectSettings"] == nil {
//            print("Json error, sb effectSettings are nil")
//            return nil
//        }
//        if map.JSON["sequencerSettings"] == nil {
//            print("Json error, sb seq settings are nil")
//            return nil
//        }
//    }
//    
//    func mapping(map: Map) {
//        name                <- map["name"]
//        id                  <- map["id"]
//        samples             <- map["samples"]
//        effectSettings      <- map["effectSettings"]
//        sequencerSettings   <- map["sequencerSettings"]
//    }
//}
