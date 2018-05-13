//  AppDelegate.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
// import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // MARK: - Firebase Auth (Check to see if user is signed in (if not new user to sign up)
        if Auth.auth().currentUser == nil {
            UserDefaults.standard.setIsLoggedIn(value: false)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            window?.rootViewController?.present(loginVC, animated: true, completion: nil)
        }
        
        // Initialize the Google Mobile Ads SDK.
        // GADMobileAds.configure(withApplicationID: "")
        
        setupGlidingCollection()
        return true
    }
    
    private func setupGlidingCollection() {
        var config = GlidingConfig.shared
        config.buttonsFont = UIFont.boldSystemFont(ofSize: 22) // Setting font for heading category titles?
        config.inactiveButtonsColor = config.activeButtonColor
        GlidingConfig.shared = config
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
    }
}
