//
//  SCDataManager.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/25/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//

import Foundation
//import ObjectMapper
import SwiftyJSON


class SCDataManager {
    
    static let shared = SCDataManager.init()
    
    var user: SCUser?
    var currentSamplePath: String?
    var currentSampleBank: Int?
   
    
    
    func fetchCurrentUserData() {
        
        guard let userJSON = readUserFile(path: "SoundCollageUser.json") else {//,
            
            // no file error, or first run
            let newUser = createUser()
            print("Created new user")
            self.user = newUser
            printAudioFilePaths()
                
            return
        }
        guard let savedUser = SCUser.init(userJSON: userJSON) else {
            print("Failed to get user data from file.")
            return
        }
        print("Fetched user data from file with success")
        self.user = savedUser
    }
    
    
    
    
    func createUser() -> SCUser {
        
        var sampleBanks: [SCSampleBank] = []
        let samples = newSampleBank()
        let sampleBankID = getNewSampleBankID()
        let effectSettings: [[SCEffectControl]] = setupEffectSettings()
        let score: [[Bool]] = setupScorePage()
        let sequencerSettings = SCSequencerSettings.init(score: score)
        let name = "SCSampleBank_ID_\(sampleBankID)"
        let sampleBank = SCSampleBank.init(name: name, sbID: sampleBankID, samples: samples, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        sampleBanks.append(sampleBank)
        let soundCollages: [String] = []
        let newUser = SCUser.init(userName: "Perrin", sampleBanks: sampleBanks, soundCollages: soundCollages)
        return newUser
    }
    
    
    
    func readUserFile(path: String) -> [String: Any]? {
        
        guard let url = getFileURL(filePath: path) else {
            print("No file at user path.")
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            print("error reading user file")
            return nil
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("user json serialization error")
            return nil
        }
        return json
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
        
        let path = "SoundCollageUser.json"

        let userJSONDict: [String: Any] = dictionaryFromUser()
        
        if (!JSONSerialization.isValidJSONObject(userJSONDict)) {
            print("is not a valid json object")
            return
        }
        
        
        do {
            let userJSONData =  try JSONSerialization.data(withJSONObject: userJSONDict, options: .prettyPrinted)
            writeToFile(jsonData: userJSONData, path: path)
        } catch let error {
            print(error.localizedDescription)
            return
        }
    }
    
    
    
    
    func dictionaryFromUser() -> [String: Any] {
      
        var dict: [String: Any] = [:]
        var sbDictArray: [[String: Any]] = []
        var ecArray1: [[[Float]]] = []
        var ecArray2: [[Float]] = []
        
        
        guard let user = SCDataManager.shared.user else {
            print("Error getting user")
            return dict
        }
        
        var sbDict: [String: Any] = [:]
        
        for (idx, _) in user.sampleBanks.enumerated() {
            
            let sb = user.sampleBanks[idx]

            // create sequencer settings
            guard let score = sb.sequencerSettings?.score else {
                return dict
            }
            sbDict.updateValue(score, forKey: "sequencerSettings")
            
            // create name
            sbDict.updateValue( sb.name, forKey: "name")
            
            // create id 
            sbDict.updateValue(sb.sbID, forKey: "sbID")
            
            
            
            // create effect settings 
            for i in sb.effectSettings {
                for j in i {
                    ecArray2.append(j.parameter)
                }
                ecArray1.append(ecArray2)
                ecArray2.removeAll()
            }
            sbDict.updateValue(ecArray1, forKey: "effectSettings")
            
            // create samples
            sbDict.updateValue(sb.samples, forKey: "samples")
            sbDictArray.append(sbDict)
        }
        
        let soundColl: [String] = user.soundCollages
        
        
        dict = ["userName": user.userName,
                                   "sampleBanks": sbDictArray,
                                   "soundCollages": soundColl
        ]
        
        return dict
    }
    
    
    
    
    func writeToFile(jsonData: Data, path: String){
    
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = NSURL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(path)
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
        
        // Write that JSON to the file created earlier
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath!)
            file.write(jsonData)
            print("JSON data was written to the file successfully!")
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString as Any)
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    
    
    
    func printAudioFilePaths(){

        
        guard let sampleBanks = SCDataManager.shared.user?.sampleBanks else {
            print("SampleBanks not found.")
            return
        }
        for sampleBank in sampleBanks {
            for value in sampleBank.samples.values {
                print(value)
            }
        }
    }
    
    
    
    
    func createNewSampleBank(){
        
        let samples = newSampleBank()
        let sampleBankID = SCDataManager.shared.getNewSampleBankID()
        let score: [[Bool]] = setupScorePage()
        let sequencerSettings = SCSequencerSettings.init(score: score)
        let effectSettings: [[SCEffectControl]] = setupEffectSettings()
        let name = "SampleBank_ID_\(sampleBankID)"
        let sampleBank = SCSampleBank.init(name: name, sbID: sampleBankID, samples: samples, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        SCDataManager.shared.user?.sampleBanks.append(sampleBank)
//        SCDataManager.shared.currentSampleBank = SCDataManager.shared.user?.sampleBanks?.last?.id
    }
    
    
    
    
    func newSampleBank() -> [String: String]{
        let samples: [String: String] = ["0": "",
                                            "1": "",
                                            "2": "",
                                            "3": "",
                                            "4": "",
                                            "5": "",
                                            "6": "",
                                            "7": "",
                                            "8": "",
                                            "9": "",
                                            "10": "",
                                            "11": "",
                                            "12": "",
                                            "13": "",
                                            "14": "",
                                            "15": ""]
        
        return samples
    }
    
    
    
    
    func setupScorePage()-> [[Bool]] { // sequencerSettings
        
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
    
    
    
    func getLastSampleBankIdx() -> Int {
        
        let idx = UserDefaults.standard.integer(forKey: "lastSampleBank")
        return idx
    }
    
    
    
    func setLastSampleBankIdx(){
        
        guard let idx = SCDataManager.shared.currentSampleBank else { return }
        UserDefaults.standard.set(idx, forKey: "lastSampleBank")
        
    }
    
    
    func setupCurrentSampleBankEffectSettings(){
        
        SCAudioManager.shared.audioController = SCGAudioController.init()
        SCAudioManager.shared.audioController?.delegate = SCAudioManager.shared as? SCGAudioControllerDelegate
        SCAudioManager.shared.audioController?.getAudioFilesForURL()
        SCAudioManager.shared.effectControls = (SCDataManager.shared.user?.sampleBanks[SCDataManager.shared.currentSampleBank!].effectSettings)!
        SCAudioManager.shared.audioController?.effectControls = SCAudioManager.shared.effectControls
        SCAudioManager.shared.isSetup = true
        if SCDataManager.shared.currentSampleBank == nil {
            SCDataManager.shared.currentSampleBank = getLastSampleBankIdx()
        }
    }
}
