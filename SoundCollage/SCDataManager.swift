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
            let samples = newStandardSampleBank()
            let sampleBankID = getSampleBankID()
            let effectSettings: [SCEffectControl] = []
            let score: [[Bool]] = SCDataManager.shared.setupScorePage()
            let sequencerSettings = SCSequencerSettings.init(score: score)
            let sampleBank = SCSampleBank.init(name: nil, id: sampleBankID, samples: samples, type: .standard, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
            

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
    
    
    
    func getSampleBankID() -> Int {
        
        let userDefaults = UserDefaults.standard
        
        guard let sampleBankID: Int = userDefaults.value(forKey: "sampleBankID") as! Int?  else {
            print("sampleBankID not found in user defaults, set to zero.")
            userDefaults.set(0, forKey: "sampleBankID")
            return 0
        }
        userDefaults.set(sampleBankID+1, forKey: "sampleBankID")
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
            print("SampleBanks not found.")
            return
        }
        for sampleBank in sampleBanks {
            for value in sampleBank.samples.values {
                print(value)
            }
        }
    }
    
    
    
    
    
    func newStandardSampleBank() -> [String: AnyObject]{
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
        
        return samples
    }
    
    
    
    
    
    func newDoubleSampleBank()-> [String: AnyObject] {
        
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
                                            "15": "" as AnyObject,
                                            "16": "" as AnyObject,
                                            "17": "" as AnyObject,
                                            "18": "" as AnyObject,
                                            "19": "" as AnyObject,
                                            "20": "" as AnyObject,
                                            "21": "" as AnyObject,
                                            "22": "" as AnyObject,
                                            "23": "" as AnyObject,
                                            "24": "" as AnyObject,
                                            "25": "" as AnyObject,
                                            "26": "" as AnyObject,
                                            "27": "" as AnyObject,
                                            "28": "" as AnyObject,
                                            "29": "" as AnyObject,
                                            "30": "" as AnyObject,
                                            "31": "" as AnyObject,
                                            "32": "" as AnyObject,
                                            "33": "" as AnyObject,
                                            "34": "" as AnyObject,
                                            "35": "" as AnyObject,
                                            ]
        return samples
    }
    
    
    func setupScorePage()-> [[Bool]] {
        
        var score: [[Bool]] = []
        while score.count < 16 {
            var page: [Bool] = []
            while page.count < 16 {
                let isSamplePlaybackEnabled = false
                page.append(isSamplePlaybackEnabled)
            }
            score.append(page)
        }
        return score
    }

    
}
