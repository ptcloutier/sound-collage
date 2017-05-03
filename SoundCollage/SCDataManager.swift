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

        if let filePath = getFileURL(filePath: "SoundCollageUser.json") {
            print("SoundCollage.user json file exists at path: \(filePath)")
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
                printAudioFilePaths()
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path or first run, no file to read until first save.")
        }
    }
    
    
    
    func getFileURL(filePath: String) -> URL? {
        
        let url = getFinishedFilePath(filePath: filePath)
        return url
    }



    func getAudioFileURL(filePath: String) -> URL? {
        
        let url = getFinishedFilePath(filePath: filePath)
        return url
    }



    private func prefixHandler(fileName: String) -> String {
        
        let prefix = "///private"
        if fileName.hasPrefix(prefix) {
            return fileName
        } else {
            let result = prefix.appending(fileName)
        return result
        }
    }



    private func getFinishedFilePath(filePath: String) -> URL? {
        
        let fileManager = FileManager.default
        let docsurl = try! fileManager.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let myurl = docsurl.appendingPathComponent(filePath)
        return myurl
    }
    
    
    
    func fetchCurrentUserData() {
        
        readJSONFromFile()
        
        guard let user = SCDataManager.shared.user else {
            let userName = "Perrin"
            var sampleBanks: [SCSampleBank] = []
            let samples: [String: AnyObject] = ["0": "" as AnyObject,
                                                "1": "" as AnyObject,
                                                "2": "" as AnyObject,
                                                "3": "" as AnyObject,
                                                "4": "" as AnyObject,
                                                "5": "" as AnyObject,
                                                "6": "" as AnyObject,
                                                "7": "" as AnyObject,
                                                "8": "" as AnyObject,
                                                "9": "" as AnyObject,
                                                "10": "" as AnyObject,
                                                "11": "" as AnyObject,
                                                "12": "" as AnyObject,
                                                "13": "" as AnyObject,
                                                "14": "" as AnyObject,
                                                "15": "" as AnyObject]
            
            let sampleBankID = getSampleBankID()
            let sampleBank = SCSampleBank.init(name: nil, id: sampleBankID, samples: samples)

            sampleBanks.append(sampleBank)
            let newUser = SCUser.init(userName: userName, sampleBanks: sampleBanks, currentSampleBank: sampleBank)
            self.user = newUser
            printAudioFilePaths()
            print("Created new user")
            return
        }
        print("Fetched user data from file with success")
        self.user = user
    }
    
    
    private func getSampleBankID() -> Int {
        
        let userDefaults = UserDefaults.standard
        
        guard let sampleBankID: Int = userDefaults.value(forKey: "sampleBankID") as! Int?  else {
            print("sampleBankID not found in user defaults, set to zero.")
            userDefaults.set(0, forKey: "sampleBankID")
            return 0
        }
        return sampleBankID+1   // increment the sampleBankID when a new one is created
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
    
    func printAudioFilePaths(){
        
        guard let sampleBanks = self.user?.sampleBanks else {
            print("No sampleBanks found in user.")
            return
        }
        for sampleBank in sampleBanks {
            for value in sampleBank.samples.values {
                print(value)
            }
        }
    }
    
//    func replaceAudioFileAtPath(filePath: URL) {
//
//        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
//        
//        guard let audioFilePath = documentsDirectoryPath.appendingPathComponent(filePath.absoluteString) else {
//            print("audio file path not found.")
//            return
//        }
//        let fileManager = FileManager.default
//        var isDirectory: ObjCBool = false
    
        // creating an audio file in the Documents folder
//        if fileManager.fileExists(atPath: filePath.absoluteString, isDirectory: &isDirectory) {
//            print("already an audio file at this path, let's overwrite it.")
//        } else {
//            print("first audio file at this path." )
//        }
//    }
}
