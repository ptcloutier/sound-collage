
//  SCUser.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation


class SCUser {
    
    var userName: String?
    var sampleBanks: [SCSampleBank]?
    var soundCollages: [String]?
//    var jsonRepresentation : String? {
//        //        let sb = self.sampleBanks.jsonRepresentation
//        let jsonDict = ["userName" : userName as Any,
//                        "sampleBanks" : sampleBanks as Any ,
//                        "soundCollages" : soundCollages as Any]
//        
//        if let data = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
//            let jsonString = String(data:data, encoding:.utf8) {
//            return jsonString
//        } else {
//            print("error serializing json string")
//            return nil }
//    }

    
    
    init(userName: String?, sampleBanks: [SCSampleBank]?, soundCollages: [String]?) {
        self.userName = userName
        self.sampleBanks = sampleBanks
        self.soundCollages = soundCollages
    }
    
    
    convenience init?(json: [String: Any]) {
        
        guard let userName = json["userName"] as? String?,
            let sampleBanks = json["sampleBanks"] as? [SCSampleBank]?,//SCSampleBank.collection(json: json["sampleBanks"] as? [String : Any]),//
            let soundCollages = json["soundCollages"] as? [String]
            else {
                print("json error")
                return nil
        }
        
        self.init(userName: userName, sampleBanks: sampleBanks, soundCollages: soundCollages)
        self.userName = userName
        self.sampleBanks = sampleBanks
        self.soundCollages = soundCollages
    }
}

//import ObjectMapper
//import Foundation
//
//class SCUser: Mappable {
//    
//    var userName: String?
//    var sampleBanks: [SCSampleBank]?
//    var soundCollages: [String]?
//    
//    init(userName: String?, sampleBanks: [SCSampleBank]?, soundCollages: [String]?) {
//        self.userName = userName
//        self.sampleBanks = sampleBanks
//        self.soundCollages = soundCollages
//    }
//    
//    required init?(map: Map) {
//        // check if a required property exists within the JSON.
//        if map.JSON["userName"] == nil {
//            print("Json error, scuser userName is nil")
//            return nil
//        }
//        if map.JSON["sampleBanks"] == nil {
//            print("Json error, scuser samplebanks are nil")
//            return nil
//        }
//        if map.JSON["soundCollages"] == nil {
//            print("Json error, scuser soundCollages are nil")
//            return nil
//        }
//    }
//    
//    
//    // Mappable
//    func mapping(map: Map) {
//        userName            <- map["userName"]
//        sampleBanks         <- map["sampleBanks"]
//        soundCollages       <- map["soundCollages"]
//    }    
//}
//
