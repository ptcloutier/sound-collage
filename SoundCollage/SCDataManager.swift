//
//  SCDataManager.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON


class SCDataManager {
    
    static let shared = SCDataManager.init()
    
    var user: SCUser?
    var currentSamplePath: String?
    
   
    
    
    func fetchCurrentUserData() {
        
        guard let savedUser = readFile() else {
            
            // no file, first run
            let newUser = createUser()
            print("Created new user")
            self.user = newUser
            printAudioFilePaths()

            return
        }
        self.user = savedUser
        print("Fetched user data from file with success")
        
    }
    
    
    
    
    func createUser() -> SCUser {
        
        var sampleBanks: [SCSampleBank] = []
        let samples = newSampleBank()
        let sampleBankID = getNewSampleBankID()
        let effectSettings: [[SCEffectControl]] = setupEffectSettings()
        let score: [[Bool]] = SCDataManager.shared.setupScorePage()
        let sequencerSettings = SCSequencerSettings.init(score: score)
        let name = "SCSampleBank_ID_\(sampleBankID)"
        let sampleBank = SCSampleBank.init(name: name, id: sampleBankID, samples: samples,effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        sampleBanks.append(sampleBank)
        let soundCollages: [String] = []
        let newUser = SCUser.init(userName: "Perrin", sampleBanks: sampleBanks, currentSampleBank: sampleBankID, soundCollages: soundCollages)
        return newUser
    }
    
    
    
    func readFile() -> SCUser? {
        
        guard let filePath = getFileURL(filePath: "SoundCollageUser.json") else {
            print("No file at path.")
            return nil
        }
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            print("File exists at path: \(filePath)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.path), options: .alwaysMapped)
                let json = JSON(data: data)
                let jsonString = json.rawString()
                let scUser = SCUser(JSONString: jsonString!)
                return scUser
            } catch let error {
                print("Error, \(error.localizedDescription)")
                return nil
            }
        } else {
            return nil
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
    
    
    
    
    
    
    func getNewSampleBankID() -> Int {
        
        let userDefaults = UserDefaults.standard
        
        guard let sampleBankID: Int = userDefaults.value(forKey: "sampleBankID") as! Int?  else {
            print("sampleBankID not found in user defaults, set to zero.")
            userDefaults.set(0, forKey: "sampleBankID")
            return 0
        }
        let newSampleID = sampleBankID+1
        userDefaults.set( newSampleID, forKey: "sampleBankID")
        return newSampleID   // increment the sampleBankID when a new one is created
    }

    
    
    
    func saveObjectToJSON(){
        
        let user = SCDataManager.shared.user
        
        if let jsonString = user?.toJSONString(prettyPrint: true){
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
            print(jsonString)
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    
    
    
    func printAudioFilePaths(){
//        let d = SCDataManager.shared.user
        
        guard let sampleBanks = SCDataManager.shared.user?.sampleBanks else {
            print("SampleBanks not found.")
            return
        }
        for sampleBank in sampleBanks {
            for value in (sampleBank.samples?.values)! {
                print(value)
            }
        }
    }
    
    
    
    
    func createNewSampleBank(){
        
        let samples = SCDataManager.shared.newSampleBank()
        let sampleBankID = SCDataManager.shared.getNewSampleBankID()
        let score: [[Bool]] = SCDataManager.shared.setupScorePage()
        let sequencerSettings = SCSequencerSettings.init(score: score)
        let effectSettings: [[SCEffectControl]] = SCDataManager.shared.setupEffectSettings()
        let uuid = UUID().uuidString
        let name = "\(uuid)_sampleBank_id_\(sampleBankID)"
        let sampleBank = SCSampleBank.init(name: name, id: sampleBankID, samples: samples, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        SCDataManager.shared.user?.sampleBanks?.append(sampleBank)
        SCDataManager.shared.user?.currentSampleBank = SCDataManager.shared.user?.sampleBanks?.last?.id
    }
    
    
    
    
    func newSampleBank() -> [String: AnyObject]{
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

    
    
    
    func setupEffectSettings()-> [[SCEffectControl]] {
        
        var effectSettings: [[SCEffectControl]] = []
        
        while effectSettings.count<Array(SCAudioManager.shared.mixerPanels.keys).count{
            var controls: [SCEffectControl] = []
            while controls.count<5{
            let ec = SCEffectControl.init()
            controls.append(ec)
            }
            effectSettings.append(controls)
        }
        
        return effectSettings
    }
    
    
    
    
    func getSelectedMixerPanelIndex()-> Int {
        
        let selectedMixerPanelIdx: Int = UserDefaults.standard.integer(forKey: "selectedMixerPanelIndex")
       
        return selectedMixerPanelIdx
    }
    
    
    
    
    func setSelectedMixerPanelIndex(index: Int){
        
        UserDefaults.standard.set(index, forKey: "selectedMixerPanelIndex")
    }
    
}
