
//
//  AppDelegate.swift
//  SoundCollage
//
//  Created by perrin cloutier on 4/19/17.
//  Copyright © 2017 ptcloutier. All rights reserved.
//
import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let dm = SCDataManager.shared
        let am = SCAudioManager.shared
        am.isSetup = false
        am.setupAudioManager() // get user and sample banks
        dm.fetchCurrentUserData()
        dm.setupCurrentSampleBankEffectSettings()
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "SCSampleBankVC") as? SCSampleBankViewController
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        checkRecordingStatus()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // if recording, stop
        checkRecordingStatus()
        SCDataManager.shared.saveObjectToJSON()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
        checkRecordingStatus()
        SCDataManager.shared.saveObjectToJSON()
    }
    
    func checkRecordingStatus(){
        if SCAudioManager.shared.isRecordingSample == true {
            SCAudioManager.shared.stopRecordingSample()
        }
        if SCAudioManager.shared.isRecordingOutput == true {
            SCAudioManager.shared.stopRecordingOutput()
        }
    }
}
