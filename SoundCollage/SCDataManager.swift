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
//            let sbJSON = readSBFile(path: "SoundCollageSampleBanks.json") else {
            
                // no file, first run
            let newUser = createUser()
            print("Created new user")
            self.user = newUser
            printAudioFilePaths()
                
                return
        }
        if let savedUser = SCUser.init(userJSON: userJSON){//, sbJSON: sbJSON){
            print("\(String(describing: savedUser.userName))")
            print("\(String(describing: savedUser.soundCollages))")
        }
        
//        for i in sbJSON {
//            print("\(String(describing: i["name"]))")
//            print("\(String(describing: i["samples"]))")
//            print("\(String(describing: i["sequencerSettings"]))")
//            print("\(String(describing: i["id"]))")
//        }
//        self.user = savedUser
//        self.user?.sampleBanks = savedSB
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
        let sampleBank = SCSampleBank.init(name: name, samples: samples, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
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
    
    
    
    func readSBFile(path: String) -> [[String: Any]]? {
        
        guard let url = getFileURL(filePath: path) else {
            print("No file at sb path.")
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            print("error reading sb file")
            return nil
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            print("sb json serialization error")
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

    
    
    
    
    
    func dictionaryFromSCUser(user: SCUser) -> [String: Any] {
        
        var dict: [String: Any] = [:]
        
        
        let unData = user.userName?.data(using: .utf8)
        let unString = String.init(data: unData!, encoding: .utf8)
    
        let scString = String(describing: user.soundCollages)
        
        dict.updateValue(unString!, forKey: "userName")
        dict.updateValue(scString, forKey: "soundCollages")
        
        let userDict: [String: [String: Any]] = ["user": dict]
        return userDict
    }

    
    
    
    func arrayOfSCSampleBanks(user: SCUser) -> [[String: Any]]{
        
        var sampBanks: [[String: Any]] = []
        
        for sb in user.sampleBanks! {
            let sbDict: [String: Any] = dictionaryFromSCSampleBank(sb: sb)
            sampBanks.append(sbDict)
        }

        return sampBanks
    }
    
    
    
    
    
    func dictionaryFromSCSampleBank(sb: SCSampleBank) -> [String: Any] {
        
        var dict: [String: Any] = [:]
        var effSettDict: [[String: Any]] = []
        
        
        for settings in sb.effectSettings! {
            for ec in settings {
                let ecDict: [String: Any] = dictionaryFromSCEffectControl(ec: ec)
                effSettDict.append(ecDict)
            }
        }
        
        let seqSetDict: [String: Any] = dictionaryFromSCSequencerSettings(ss: sb.sequencerSettings!)
        
        
        dict.updateValue(String(describing:sb.name!), forKey: "name")
        dict.updateValue(String(describing:sb.samples), forKey: "samples")
        dict.updateValue(String(describing:effSettDict), forKey: "effectSettings")
        dict.updateValue(String(describing:seqSetDict), forKey: "sequencerSettings")
        return dict
    }
    
    
    
    
    func dictionaryFromSCEffectControl(ec: SCEffectControl) -> [String: Any] {
        
        var dict: [String: Any] = [:]
        dict.updateValue(String(describing:ec.parameter), forKey: "parameter")
        return dict
    }
    
    
    
    func dictionaryFromSCSequencerSettings(ss: SCSequencerSettings) -> [String: Any] {
        
        var dict: [String: Any] = [:]
        dict.updateValue(String(describing: ss.score), forKey: "score")
        dict.updateValue(String(describing: ss.timeSignature), forKey: "timeSignature")
        return dict
    }
    
    
    func jsonToString(json: AnyObject) -> String? {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString
        } catch let myJSONError {
            print(myJSONError)
            return nil
        }
    }

    func saveObjectToJSON(){
        
        let userJSONString = jsonToString(json: SCDataManager.shared.user!)
        
        
        
//        let userJSON: [String: Any] = //dictionaryFromSCUser(user: SCDataManager.shared.user!)
//        let sampleBanksJSON: [[String: Any]] = //arrayOfSCSampleBanks(user: SCDataManager.shared.user!)
        
        
        
        doWriteToFile(json: userJSONString!, path: "SoundCollageUser.json")
//        doWriteToFile(json: sampleBanksJSON, path: "SoundCollageSampleBanks.json")
        //        do {
        //            let userData = try JSONSerialization.data(withJSONObject: userJSON, options: .prettyPrinted)
        //            if let userJsonString = String(data: userData, encoding: .utf8) {
        //                print(userJsonString)
        //                writeToFile(jsonString: userJsonString)
        //            } else {
        //               print("Error, couldn't get json string from data")
        //            }
        //        } catch let error {
        //           print("\(error.localizedDescription)")
        //        }
        
        //        do {
        //            let data = try JSONSerialization.data(withJSONObject: sampleBanksJSON, options: .prettyPrinted)
        //            if let jsonString = String(data: data, encoding: .utf8) {
        //                print(jsonString)
        //                writeToFile(jsonString: jsonString)
        //            } else {
        //                print("Error, couldn't get json string from data")
        //            }
        //        } catch let error {
        //            print("\(error.localizedDescription)")
        //        }
    }
    
    private func doWriteToFile(json: Any, path: String){
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
                writeToFile(jsonString: jsonString, path: path)
            } else {
                print("Error, couldn't get json string from data")
            }
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }
    
    
    
    func writeToFile(jsonString: String, path: String){
    
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
        
        let samples = SCDataManager.shared.newSampleBank()
        let sampleBankID = SCDataManager.shared.getNewSampleBankID()
        let score: [[Bool]] = SCDataManager.shared.setupScorePage()
        let sequencerSettings = SCSequencerSettings.init(score: score)
        let effectSettings: [[SCEffectControl]] = SCDataManager.shared.setupEffectSettings()
        let name = "SampleBank_ID_\(sampleBankID)"
        let sampleBank = SCSampleBank.init(name: name, samples: samples, effectSettings: effectSettings, sequencerSettings: sequencerSettings)
        SCDataManager.shared.user?.sampleBanks?.append(sampleBank)
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
        SCAudioManager.shared.effectControls = (SCDataManager.shared.user?.sampleBanks?[SCDataManager.shared.currentSampleBank!].effectSettings)!
        SCAudioManager.shared.audioController?.effectControls = SCAudioManager.shared.effectControls
        SCAudioManager.shared.isSetup = true
        if SCDataManager.shared.currentSampleBank == nil {
            SCDataManager.shared.currentSampleBank = SCDataManager.shared.getLastSampleBankIdx()
        }
    }
    
}
