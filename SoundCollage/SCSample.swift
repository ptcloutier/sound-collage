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
    var title: String!
    var url: String!
    
    init(sampleBankID: Int!, url: String!, title: String!) {
        self.sampleBankID = sampleBankID
        self.url = url
        self.title = title
    }
    required init?(map: Map) {
        sampleBankID    <- map["sampleBankID"]
        url             <- map["url"]
        title           <- map["title"]
    }
//    // Mappable
    func mapping(map: Map) {
        sampleBankID    <- map["sampleBankID"]
        url             <- map["url"]
        title           <- map["title"]
    }

}
