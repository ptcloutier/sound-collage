//
//  SCUser.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCUser: Mappable { // then just save a file like user.json
    //to docs dir
    
    static let shared = SCUser(sampleBanks:[])
    
    var sampleLibrary:[SCSample]?
    var sampleBanks: [SCSampleBank]?
    var currentSampleBank: SCSampleBank?
    
    required init?(map: Map) {
        // check if a required "name" property exists within the JSON.
        if map.JSON["sampleBanks"] == nil {
            return nil
        }
    }
    // Mappable
    func mapping(map: Map) {
        sampleBankID    <- map["sampleBankID"]
        libraryID       <- map["libraryID"]
        url             <- map["url"]
    }
    
    func saveObjectToJSON(){
        
        let jsonString = self.toJSONString(prettyPrint: true)
        print(jsonString)
        
    }
    
    func fetchObjectFromJSON(){
        let user = User(JSONString: JSONString)
        
    }

}
