//
//  SCDataManager.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/24/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation


class SCDataManager {
    
    static let shared = SCDataManager(sampleBanks:[])
    
    var sampleBanks: [SCSampleBank] = []
    var currentSampleBank: SCSampleBank?
    
    init(sampleBanks: [SCSampleBank]) {
        self.sampleBanks = sampleBanks
    }
}
