//  AppDelegate.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import Armchair
import Siren
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // Override System Font
        UIFont.overrideInitialize()
        
        // Splash
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController")
//        self.window?.rootViewController = splashVC
//        self.window?.makeKeyAndVisible()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: "adMobAppID")
        
        // Armchair Review Manager
        Armchair.appID(appID) // always has to be first
        Armchair.daysUntilPrompt(7)
        Armchair.usesUntilPrompt(5)
        // Armchair.debugEnabled = true
        Armchair.shouldPromptClosure( { info -> Bool in
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                return false
            } else {
                return true
            }
        })
        
        // Armchair.userDidSignificantEvent(true) use on significant events in app (present review)
        // Armchair.resetUsageCounters()
        // Armchair.resetAllCounters()
        
        // Siren Updates Alert
        let siren = Siren.shared
        siren.alertType = .option
        siren.alertMessaging = SirenAlertMessaging(updateTitle: "We recently updated the app: - Something updated", updateMessage: "", updateButtonMessage: "Update Now", nextTimeButtonMessage: "Maybe Next Time", skipVersionButtonMessage: "Skip")
        siren.showAlertAfterCurrentVersionHasBeenReleasedForDays = 5
        siren.checkVersion(checkType: .weekly)
        
        setupGlidingCollection()
        
        return true
    }
    
    private func setupGlidingCollection() {
        var config = GlidingConfig.shared
        config.buttonsFont = UIFont.gillsRegFont(ofSize: 45) // Category text
        config.activeButtonColor = UIColor.darkGray
        GlidingConfig.shared.inactiveButtonsColor = config.activeButtonColor
        GlidingConfig.shared.cardsSize = CGSize(width: round(UIScreen.main.bounds.width * 0.7), height: round(UIScreen.main.bounds.height * 0.45))
        config.inactiveButtonsColor = config.activeButtonColor
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Siren Update Alert Checks
        Siren.shared.checkVersion(checkType: .weekly)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Siren Update Alert Checks
        Siren.shared.checkVersion(checkType: .weekly)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}
