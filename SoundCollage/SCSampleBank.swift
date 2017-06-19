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
    
    init(name: String?, id: Int?, samples: [String: AnyObject], type: SamplerType) {
        self.name = name
        self.id = id
        self.samples = samples
        self.type = type
    }
    
    required init?(map: Map) {
        samples     <- map["samples"]
        name        <- map["name"]
        id          <- map["id"]
        type        <- map["type"]
    }
    
    func mapping(map: Map) {
        samples     <- map["samples"]
        name        <- map["name"]
        id          <- map["id"]
        type        <- map["type"]
    }
    
    enum SamplerType {
        case standard
        case double
    }

}
