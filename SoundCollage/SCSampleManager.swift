//
//  SampleManager.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSampleManager {
    
    static let shared = SCSampleManager(sampleBank:[])
    
    var sampleBank: [SCSample] = []
    
    init(sampleBank: [SCSample]) {
        self.sampleBank = sampleBank
    }
    
    
    
    
    
    
    
}
