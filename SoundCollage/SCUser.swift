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
    var currentSampleBank: Int?
    var soundCollages: [String]?
    
    init(userName: String?, sampleBanks: [SCSampleBank]?, currentSampleBank: Int?, soundCollages: [String]?) {
        self.userName = userName
        self.sampleBanks = sampleBanks
        self.currentSampleBank = currentSampleBank
        self.soundCollages = soundCollages
    }
    
    required init?(map: Map) {
        userName            <- map["userName"]
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        soundCollages       <- map["soundCollages"]
    }
    
    
    // Mappable
    func mapping(map: Map) {
        userName            <- map["userName"]
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        soundCollages       <- map["soundCollages"]
    }    
}

