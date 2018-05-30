//  Wallpaper.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.


import UIKit
import Firebase
import SwiftyJSON

struct Wallpaper {
    
    let user: User
    var wallpaperURL: String?
    var wallpaperDesc: String!
    var wallpaperCategory: String!
    private var wallpaperImage: UIImage!
    
    var sportsCategory = [String]()
    var musicCategory = [String]()
    var artCategory = [String]()
    
//    public init(wallpaperImage: UIImage, wallpaperDesc: String, wallpaperCategory: String) {
//        self.wallpaperCategory = wallpaperCategory
//        self.wallpaperImage = wallpaperImage
//        self.wallpaperDesc = wallpaperDesc
//    }
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.wallpaperURL = dictionary["wallpaperURL"] as? String ?? ""
        self.wallpaperDesc = dictionary["wallpaperDesc"] as? String ?? ""
        self.wallpaperCategory = dictionary["wallpaperCategory"] as? String ?? ""
    }
}

//    // MARK: Intializer for Wallpapers to go into Wallpapers Feed (turn into Firebase database in JSON format)
//    public init(snapshot: DataSnapshot) {
//        let json = JSON(snapshot.value!)
//        self.wallpaperURL = json["wallpaperURL"].stringValue
//        self.wallpaperDesc = json["wallpaperDesc"].stringValue
//        self.wallpaperCategory = json["wallpaperCategory"].stringValue
//
//    }
//
//    // MARK: - Function for uploading Wallpapers to Firebase
//    func uploadWallpaper() {
//        let newWallRef = databaseReference.child("wallpapers").childByAutoId() // Puts uploaded wallpaper images in database under "wallpapers", eventually put in proper category
//        let newWallKey = newWallRef.key
//
//        if let wallpaperData = UIImagePNGRepresentation(self.wallpaperImage) {
//            let wallpaperStorageRef = Storage.storage().reference().child("images") // saves image to storage under "images", later assign category
//            let newWallpaperImageRef = wallpaperStorageRef.child(newWallKey)
//
//            newWallpaperImageRef.putData(wallpaperData).observe(.success, handler: { (snapshot) in
//                self.wallpaperURL = snapshot.metadata?.path
//                    // snapshot.metadata?.downloadURL()?.absoluteString
//                let newWallpaperDictionary = [ // creates dictionary of wallpaper info, once uploaded to storage: url, category, desc
//                    "wallpaperURL": self.wallpaperURL,
//                    "wallpaperCategory": self.wallpaperCategory,
//                    "wallpaperDesc": self.wallpaperDesc
//                ]
//                newWallRef.setValue(newWallpaperDictionary)
//            })
//        }
//    }
//    // MARK: Firebase Category Functions
//    func getSportsCategory() {
//        self.sportsCategory = [] //init it any time this func is called.
//        let wallpapersRef = databaseReference.child("wallpapers")
//        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "sports")
//
//        queryRef.observe(.value, with: { snapshot in
//
//            if ( snapshot.value is NSNull ) {
//                print("no snapshot made found from music node")
//            } else {
//
//                for child in (snapshot.children) {
//
//                    let snap = child as! DataSnapshot //each child is a snapshot
//
//                    let sportsDict = snap.value as! [String: String] // make art dict from art node in firebase ata
//
//                    let wallpaperCategoryTitle = sportsDict["wallpaperCategory"]
//                    let wallpaperDesc = sportsDict["wallpaperDesc"]
//                    let wallpaperURL = sportsDict["wallpaperURL"]
//                    self.sportsCategory.append(wallpaperCategoryTitle!)
//                    self.sportsCategory.append(wallpaperDesc!)
//                    self.sportsCategory.append(wallpaperURL!)
//                }
//            }
//        })
//    }
//    //        databaseReference.child("wallpapers").queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "sports").observe(.childAdded, with: { (snapshot) in
//    //            var sportsCategory = [Wallpaper]()
//    //            if let sportsCatSnapshot = snapshot.children.allObjects as? [DataSnapshot] {
//    //                for snapshot in sportsCatSnapshot {
//    //                    let sportsCat = Wallpaper(snapshot: snapshot)
//    //                    sportsCategory.append(sportsCat)
//    //                }
//    //            }
//    //        })
//    //    }
//    //   MARK: Categories Function SwiftyJSON way, need to call firebase database
//    // class func from(json: JSON) -> SportsCategory? {
//    // var wallpaperCategory: String
//    // if let unwrappedwallCatTitle = json["wallpaperCategory"].string {
//    // wallpaperCategory = unwrappedwallCatTitle
//    // } else {
//    // wallpaperCategory = ""
//    // }
//    // let wallpaperDesc = json["wallpaperDesc"].string
//    // let wallpaperURL = json["wallpaperURL"].string
//    // return SportsCategory(wallpaperCategory: wallpaperCategory, wallpaperDesc: wallpaperDesc, wallpaperURL:  wallpaperURL)
//    // }
//    // }
//
//    func getMusicCategory() {
//        self.musicCategory = [] //init it any time this func is called.
//        let wallpapersRef = databaseReference.child("wallpapers")
//        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "music")
//
//        queryRef.observe(.value, with: { snapshot in
//
//            if ( snapshot.value is NSNull ) {
//                print("no snapshot made found from music node")
//            } else {
//
//                for child in (snapshot.children) {
//
//                    let snap = child as! DataSnapshot //each child is a snapshot
//
//                    let musicDict = snap.value as! [String: String] // make art dict from art node in firebase ata
//
//                    let wallpaperCategoryTitle = musicDict["wallpaperCategory"]
//                    let wallpaperDesc = musicDict["wallpaperDesc"]
//                    let wallpaperURL = musicDict["wallpaperURL"]
//                    self.musicCategory.append(wallpaperCategoryTitle!)
//                    self.musicCategory.append(wallpaperDesc!)
//                    self.musicCategory.append(wallpaperURL!)
//                }
//            }
//        })
//    }
//
//    func getArtCategory() {
//        self.artCategory = [] //init it any time this func is called.
//        let wallpapersRef = databaseReference.child("wallpapers")
//        let queryRef = wallpapersRef.queryOrdered(byChild: "wallpaperCategory").queryEqual(toValue: "art")
//
//        queryRef.observe(.value, with: { snapshot in
//
//            if ( snapshot.value is NSNull ) {
//                print("no snapshot made found from art node")
//            } else {
//
//                for child in (snapshot.children) {
//
//                    let snap = child as! DataSnapshot //each child is a snapshot
//
//                    let artDict = snap.value as! [String: String] // make art dict from art node in firebase ata
//
//                    let wallpaperCategoryTitle = artDict["wallpaperCategory"]
//                    let wallpaperDesc = artDict["wallpaperDesc"]
//                    let wallpaperURL = artDict["wallpaperURL"]
//                    self.artCategory.append(wallpaperCategoryTitle!)
//                    self.artCategory.append(wallpaperDesc!)
//                    self.artCategory.append(wallpaperURL!)
//                }
//            }
//        })
//    }
