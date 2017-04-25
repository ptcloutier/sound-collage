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
    
    var samples: [SCSample]!
    var name: String?
    var id: Int?
    
    init(name: String?, id: Int?, samples: [SCSample]?) {
        self.name = UUID.init().uuidString
        self.id = 1
        self.samples = []
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
