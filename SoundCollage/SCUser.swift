//
//  SCUser.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//
import ObjectMapper
import Foundation

class SCUser: Mappable { // then just save a file like user.json
    //to docs dir
    
//    static let shared = SCUser.init()
    
    var userName: String?
    var sampleBanks: [SCSampleBank]?
    var currentSampleBank: SCSampleBank?
    var sampleLibrary: [SCSample]?
//    var sampleBankID: Int?
//    var libraryID: Int?
//    var url: URL?

    
    init(userName: String?, sampleBanks: [SCSampleBank]?, currentSampleBank: SCSampleBank?, sampleLibrary: [SCSample]?) {
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
//        sampleBankID        <- map["sampleBankID"]
//        libraryID           <- map["libraryID"]
//        url                 <- map["url"]
        sampleBanks         <- map["sampleBanks"]
        currentSampleBank   <- map["currentSampleBank"]
        sampleLibrary       <- map["sampleLibrary"]
        userName            <- map["userName"]
    }


    
//    func fetchObjectFromJSON(){
//        let user = SCUser(JSONString: JSONString)
//        self.sampleBankID = user.sampleBank
//        self.libraryID = Int?
//        self.url = URL
//    }
    
}

