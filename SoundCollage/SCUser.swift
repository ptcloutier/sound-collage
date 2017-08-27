
//  SCUser.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation


class SCUser {
    
    var userName: String = ""
    var sampleBanks: [SCSampleBank] = []
    var soundCollages: [String] = []

    
    init(userName: String, sampleBanks: [SCSampleBank], soundCollages: [String]) {
        self.userName = userName
        self.sampleBanks = sampleBanks
        self.soundCollages = soundCollages
    }
    
    
    convenience init?(userJSON: [String: Any]) {


        guard let userName = userJSON["userName"] as? String,
            let sampleBanks = userJSON["sampleBanks"] as? [SCSampleBank],
            let soundCollages = userJSON["soundCollages"] as? [String]
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
 
