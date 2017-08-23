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
    var id: Int?
    var samples: [String: AnyObject]?
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
    
    
    init(name: String?, id: Int?, samples: [String: AnyObject]?, effectSettings: [[SCEffectControl]]? , sequencerSettings: SCSequencerSettings? ) {
        self.name = name
        self.id = id
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }

    
    convenience init?(json: [String: Any]) {
        
        guard let name = json["name"] as? String?,
            let id = json["id"] as? Int?,
            let samples = json["samples"] as? [String: AnyObject]?,
            let effectSettings = json["effectSettings"] as? [[SCEffectControl]]?,
            let sequencerSettings = json["sequencerSettings"] as? SCSequencerSettings?
            else {
                print("json error")
                return nil
        }
        self.init(name: name, id: id, samples: samples, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        self.name = name
        self.id = id
        self.samples = samples
        self.effectSettings = effectSettings
        self.sequencerSettings = sequencerSettings
    }
    
    class func collection(json: [String: Any]) -> [SCSampleBank]? {
        let sbArray = Array(json.values)
        return sbArray.map({ SCSampleBank.init(json: $0 as! [String : Any])! })
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
