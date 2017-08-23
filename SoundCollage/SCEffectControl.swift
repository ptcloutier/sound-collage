//
//  SCEffect.swift
//  SoundCollage
//
//  Created by perrin cloutier on 6/5/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import AVFoundation


class SCEffectControl {
    
    var parameter: [Float] = []
    
    init() {
        self.parameter = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    }
    
    
    convenience init?(json: [String: Any]) {
        
        guard let parameter = json["parameter"] as? [Float] else {
            print("json error")
            return nil
        }
        
        self.init()
        self.parameter = parameter
    }
}

//import ObjectMapper
//
//
//class SCEffectControl: Mappable {
//
//    var parameter: [Float] = []
//    
//    init() {
//        self.parameter = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
//    }
//    
//    
//    required init?(map: Map) {
//        // check if a required property exists within the JSON.
//        if map.JSON["parameter"] == nil {
//            print("Json error, sceffectcontrol parameter is nil")
//            return nil
//        }
//    }
//    
//    
//    func mapping(map: Map) {
//        parameter     <- map["parameter"]
//    }
//}
