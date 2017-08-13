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

    var parameter: [Float] = []
    
    init() {
        self.parameter = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    }
    
    
    required init?(map: Map) {
        parameter     <- map["parameter"]
    }
    
    
    func mapping(map: Map) {
        parameter     <- map["parameter"]
    }
}
