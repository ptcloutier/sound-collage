//
//  SCUser.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//
import ObjectMapper
import Foundation

class SCUser: Mappable {
    
    // color preference can be set on the datamanager user
    var userName: String?
    var sampleBanks: [SCSampleBank]?
    var currentSampleBank: SCSampleBank?
    var sampleLibrary: [SCAudioFile]?

    
    init(userName: String?, sampleBanks: [SCSampleBank]?, currentSampleBank: SCSampleBank?, sampleLibrary: [SCAudioFile]?) {
        self.userName = userName
        self.sampleBanks = sampleBanks
        self.currentSampleBank = currentSampleBank
        self.sampleLibrary = sampleLibrary
    }
    
    required init?(map: Map) {
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        sampleLibrary       <- map["sampleLibrary"]
        userName            <- map["userName"]
    
    }
    
    
    // Mappable
    func mapping(map: Map) {
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        sampleLibrary       <- map["sampleLibrary"]
        userName            <- map["userName"]
    }    
}

