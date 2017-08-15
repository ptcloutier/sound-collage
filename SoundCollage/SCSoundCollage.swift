//
//  SCSoundCollage.swift
//  SoundCollage
//
//  Created by perrin cloutier on 8/14/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//
import Foundation
import ObjectMapper


struct SCSoundCollage {
    
    var filePath: String?
    
    init(filePath: String?){
        self.filePath = filePath
    }
    
    init?(map: Map) {
        
        filePath 	<- map["filePath"]
    }
    
    
    mutating func mapping(map: Map) {
        
        filePath 	<- map["filePath"]
    }
}
