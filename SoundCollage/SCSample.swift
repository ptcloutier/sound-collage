//
//  URL+key.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/11/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSample {
    
    var sampleBankID: Int
    var libraryID: Int?
    var url: URL
    
    init(sampleBankID: Int, url: URL) {
        self.sampleBankID = sampleBankID
        self.url = url
    }
//    required init?(map: Map) {
//        // check if a required "name" property exists within the JSON.
//        if map.JSON["sampleBankID"] == nil {
//            return nil
//        }
//    }
//    // Mappable
//    func mapping(map: Map) {
//        sampleBankID    <- map["sampleBankID"]
//        libraryID       <- map["libraryID"]
//        url             <- map["url"]
//    }

}
