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
    
    var userName: String?
    var sampleBanks: [SCSampleBank]?
    var currentSampleBank: SCSampleBank?

    
    init(userName: String?, sampleBanks: [SCSampleBank]?, currentSampleBank: SCSampleBank?) {
        self.userName = userName
        self.sampleBanks = sampleBanks
        self.currentSampleBank = currentSampleBank
    }
    
    required init?(map: Map) {
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        userName            <- map["userName"]
    
    }
    
    
    // Mappable
    func mapping(map: Map) {
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        userName            <- map["userName"]
    }    
}

