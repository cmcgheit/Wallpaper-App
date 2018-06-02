//  Constants.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import Foundation
import Firebase

// Firebase
let storageRef = Storage.storage().reference()
let databaseRef = Database.database().reference()
let authRef = Auth.auth()


var appID = "1391180766" // from itunesconnect
var adMobAppID = "" // Google AdMob

// Colors
var tealColor = UIColor(red: 0.02, green: 0.56, blue: 0.65, alpha: 1.0) // #0690a6
var greenColor = UIColor(red: 0.02, green: 0.74, blue: 0.68, alpha: 1.0) // #06bcad
var goldColor = UIColor(red: 0.89, green: 0.78, blue: 0.36, alpha: 0.36) // EDC65B
var redColor = UIColor(red: 0.77, green: 0.28, blue: 0.38, alpha: 1.0) // #ae5389
var orangeColor = UIColor(red: 0.90, green: 0.55, blue: 0.38, alpha: 1.0) // #e58d62
var purpleColor = UIColor(red: 0.44, green: 0.09, blue: 9.67, alpha: 1.0) // #7117aa


