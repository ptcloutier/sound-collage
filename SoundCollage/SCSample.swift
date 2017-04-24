//
//  URL+key.swift
//  AudioRecorder
//
//  Created by perrin cloutier on 4/11/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation

class SCSample {
    
    var samplerID: Int
    var libraryID: Int?
    var url: URL
    
    init(samplerID: Int, url: URL) {
        self.samplerID = samplerID
        self.url = url
    }

}
