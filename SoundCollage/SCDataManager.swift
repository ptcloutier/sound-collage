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

        if let filePath = getFileURL(fileName: "SoundCollageUser.json") {
        print(filePath)
            if FileManager.default.fileExists(atPath: filePath.path){
                print("Read filepath with success ")
            }
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.path), options: .alwaysMapped)
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString!)
                let user = SCUser(JSONString: jsonString!)
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
    
    
    
    func fetchCurrentUserData() {
        
        readJSONFromFile()
        
        guard let user = SCDataManager.shared.user else {
            print("Created new user")
            let userName = "Perrin"
            let sampleBanks: [SCSampleBank] = []
            let sampleLibrary: [SCAudioFile] = []
            let samples: [SCAudioFile] = []
            let currentSampleBank = SCSampleBank.init(name: UUID.init().uuidString, id: 1, samples: samples)
            let newUser = SCUser.init(userName: userName, sampleBanks: sampleBanks, currentSampleBank: currentSampleBank, sampleLibrary: sampleLibrary)
            self.user = newUser
            return
        }
        print("Fetched user data from file with success")
        self.user = user
    }
    

    func saveObjectToJSON(){
        
        if let jsonString = SCDataManager.shared.user?.toJSONString(prettyPrint: true){
            print(jsonString)
            writeToFile(jsonString: jsonString)
        } else {
            print("Error serializing json")
        }
    }
    
    
    
    func writeToFile(jsonString: String){
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("SoundCollageUser.json")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
        if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
            let created = fileManager.createFile(atPath: (jsonFilePath?.absoluteString)!, contents: nil, attributes: nil)
            if created {
                print("File created successfully")
            } else {
                print("Error creating SoundCollageUser.json")
            }
        } else {
            print("File already exists at path: \(documentsDirectoryPathString)")
        }
        
        let jsonData: Data = jsonString.data(using: .utf8)!
        // Write that JSON to the file created earlier
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath!)
            file.write(jsonData)
            print("JSON data was written to the file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
        
    }

}
