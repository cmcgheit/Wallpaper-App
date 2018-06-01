//  Wallpaper.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.


import UIKit
import Firebase

struct Wallpaper {
    
    let user: User
    var wallpaperURL: String?
    var wallpaperDesc: String!
    var wallpaperCategory: String!
    private var wallpaperImage: UIImage!
    
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

