//
//  URL+key.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/11/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import ObjectMapper

class SCSample: Mappable {
    
    var sampleBankID: Int!
    var url: URL!
    
    init(sampleBankID: Int, url: URL) {
        self.sampleBankID = sampleBankID
        self.url = url
    }
    required init?(map: Map) {
        sampleBankID    <- map["sampleBankID"]
        url             <- map["url"]
 
    }
//    // Mappable
    func mapping(map: Map) {
        sampleBankID    <- map["sampleBankID"]
        url             <- map["url"]
    }

}
