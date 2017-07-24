//
//  SCEffect.swift
//  SoundCollage
//
//  Created by perrin cloutier on 6/5/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import AVFoundation
import ObjectMapper



class SCEffectControl: Mappable {

//    var isActive: Bool = false 
    var effectName: String?
    var parameters: [[Float]] = []
    var isPadEnabled: [Bool] = []
    
    init(effectName: String?) {
        self.effectName = effectName
        self.parameters = [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]
        while self.isPadEnabled.count < 16 {
            let value = false
            self.isPadEnabled.append(value)
        }
    }
    
    required init?(map: Map) {
        effectName     <- map["effectName"]
        parameters     <- map["parameters"]
        isPadEnabled    <- map["isPadEnabled"]
    }
    
    func mapping(map: Map) {
        effectName     <- map["effectName"]
        parameters     <- map["parameters"]
        isPadEnabled    <- map["isPadEnabled"]
    }

}
