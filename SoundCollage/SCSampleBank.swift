//
//  SCSampleBank.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSampleBank {
    
    var samples: [SCSample] = []
    var id: Int {
        guard let lastID = UserDefaults.standard.value(forKey: "id") as? Int else {
            return 0
        }
        let newID = lastID+1
        return newID
    }
    
    init() {
       
    }

}
