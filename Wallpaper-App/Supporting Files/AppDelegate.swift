//  AppDelegate.swift
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // Override System Font
        UIFont.overrideInitialize()
        
        // Splash
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = splashVC
        self.window?.makeKeyAndVisible()
        
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: adMobAppID)
        
        // Armchair Review Manager
        Armchair.appID(appID) // always has to be first
        Armchair.daysUntilPrompt(7)
        Armchair.usesUntilPrompt(5)
        // Armchair.debugEnabled = true
        Armchair.shouldPromptClosure( { info -> Bool in
            if #available(iOS 10.3, *) {
                StoreReviewHelper.checkAndAskForReview()
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
        siren.presentationManager = PresentationManager(alertTitle: "We recently updated the app: **Thing Updated", nextTimeButtonTitle: "Maybe Next Time")
        let rules = Rules(promptFrequency: .weekly, forAlertType: .none)
        siren.rulesManager = RulesManager(globalRules: rules)
        
        siren.wail(performCheck: .onDemand) { (results, error) in
           
        }
        
        // Gliding
        setupGlidingCollection()
        
        // Set Theme, defaults to light, checks for light when leaves app
        if Defaults.object(forKey: "lightTheme") != nil {
            Theme.current = Defaults.bool(forKey: "lightTheme") ? LightTheme() : DarkTheme()
        }
        
        return true
    }
    
    private func setupGlidingCollection() {
        var config = GlidingConfig.shared
        config.buttonsFont = UIFont.gillsRegFont(ofSize: 60) // Category text
        config.activeButtonColor = Theme.current.textColor
        config.inactiveButtonsColor = Theme.current.textColor
        config.cardsSize = CGSize(width: round(UIScreen.main.bounds.width * 0.7), height: round(UIScreen.main.bounds.height * 0.75))
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // sign out user when app terminated
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            AuthService.instance.logOutUser()
            FIRService.removeFIRObservers()
            Defaults.setIsLoggedIn(value: false)
        }
    }
}
