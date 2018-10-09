//  Constants.swift
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import Foundation
import Firebase

let ApplicationName = "Wall Variety"
let ApplicationFBLink = "https://www.facebook.com/"
let ApplicationTwitterLink = "https://www.twitter.com/"
let ApplicationInstagramLink = "https://www.instagram.com/"

// Firebase
let storageRef = Storage.storage().reference()
let databaseRef = Database.database().reference()
let authRef = Auth.auth()

// SwiftKeychainWrapper
let KEY_UID = "uid" // Keychain Wrapper UID

// Google Ads
var appID = "1391180766" // from itunesconnect
var adMobAppID = "" // Google AdMob

// Terms PDF
let termsPDF = "WallVarietyTerms.pdf"

// Colors
var tealColor = UIColor(red: 0.02, green: 0.56, blue: 0.65, alpha: 1.0) // #0690a6
var wallBlue = UIColor(red: 0.2627, green: 0.6275, blue: 0.7294, alpha: 1.0) // #43A0BA
var wallGold = UIColor(red: 0.9686, green: 0.7765, blue: 0.5137, alpha: 1.0) // #F7C683
var wallDarkBlue = UIColor(red: 0.2039, green: 0.502, blue: 0.5686, alpha: 1.0) // #348091
var wallPink = UIColor(red: 0.9059, green: 0.5355, blue: 0.5804, alpha: 1.0) // #E78694
var greenColor = UIColor(red: 0.02, green: 0.74, blue: 0.68, alpha: 1.0) // #06bcad
var goldColor = UIColor(red: 0.89, green: 0.78, blue: 0.36, alpha: 0.36) // EDC65B
var redColor = UIColor(red: 0.77, green: 0.28, blue: 0.38, alpha: 1.0) // #ae5389
var orangeColor = UIColor(red: 0.90, green: 0.55, blue: 0.38, alpha: 1.0) // #e58d62
var purpleColor = UIColor(red: 0.44, green: 0.09, blue: 9.67, alpha: 1.0) // #7117aa

// UserDefaults
let Defaults = UserDefaults.standard


