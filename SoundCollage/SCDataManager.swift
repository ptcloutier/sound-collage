//
//  SCDataManager.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import ObjectMapper

class SCDataManager {
    
    static let shared = SCDataManager.init()
    
    var user: SCUser?
    var currentSampleTitle: String?
    
    func readJSONFromFile(){
//        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
//        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//      let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
  //    let jsonFilePath = documentsDirectoryPath.appendingPathComponent("user.json")

//        let textFileURL = documentsPath.appendingPathComponent("resource/data/introduction")
//        let fileURLString = textFileURL?.path
//        
//        let filePath = getFileURL(fileName: "user.json")
//
//        print(filePath!)
        // /Users/perrincloutier/Library/Developer/CoreSimulator/Devices/F515D532-D5E5-4707-9BB2-257557B4F484/data/Containers/Data/Application/765E55FE-3059-4C8E-8CA6-82920EC2A0DA/Documents
        // /Users/perrincloutier/Library/Developer/CoreSimulator/Devices/F515D532-D5E5-4707-9BB2-257557B4F484/data/Containers/Data/Application/B5A0F063-1534-4D92-8A8B-F63762F88EAA/Documents
        // /Users/perrincloutier/Library/Developer/CoreSimulator/Devices/F515D532-D5E5-4707-9BB2-257557B4F484/data/Containers/Data/Application/25983913-4A07-416D-96B1-B0FCC29F60E9/Documents
        // /Users/perrincloutier/Library/Developer/CoreSimulator/Devices/F515D532-D5E5-4707-9BB2-257557B4F484/data/Containers/Data/Application/708F54FD-1188-4C27-9F6B-A25D8A951526/Documents
        
        
//        if let path = Bundle.main.path(forResource: "user" , ofType: "json") {
        if let filePath = getFileURL(fileName: "SoundCollageUser.json") {
        print(filePath)
            if FileManager.default.fileExists(atPath: filePath.path){
                print("success")
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.path), options: .alwaysMapped)
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString!)
                let user = SCUser(JSONString: jsonString!)
//                let user = Mapper<SCUser>().map(JSONString: jsonString!)
                //let jsonObj = JSONSerializer.toJson(data)
                print(user!)
                self.user = user 
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        
        }
        
    }
    func getFileURL(fileName:String) -> URL? {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            return directoryContents.first{$0.absoluteString.contains(fileName)}
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }

//    let fileManager = FileManager.default
//    var isDirectory: ObjCBool = false
//    
//    // creating a .json file in the Documents folder
//    if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
//    let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
//    if created {
//    print("File created ")
//    } else {
//    print("Couldn't create file for some reason")
//    }
//    } else {
//    print("File already exists")
//    }

}
