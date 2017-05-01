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
    
    var samples: [String: AnyObject] = [:] // object mapper not retrieving dict values
    var name: String? // for the user to identify the sample bank
    var id: Int?
    
    init(name: String?, id: Int?, samples: [String: AnyObject]) {
        self.name = name
        self.id = id
        self.samples = samples
    }
    
    required init?(map: Map) {
        samples     <- map["samples"]
        name        <- map["name"]
        id          <- map["id"]
    }
    
    func mapping(map: Map) {
        samples     <- map["samples"]
        name        <- map["name"]
        id          <- map["id"]
    }

}
