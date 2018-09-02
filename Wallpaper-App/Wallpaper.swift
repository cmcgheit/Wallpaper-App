//  Wallpaper.swift
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.


import UIKit
import Firebase

struct Wallpaper {
    
    // let user: User
    var wallpaperURL: String?
    var wallpaperDesc: String?
    var wallpaperCategory: String! // WallpaperCategory()
    private var wallpaperImage: UIImage!
        
    init(dictionary: [String: Any]) { // user: User
        // self.user = user
        self.wallpaperURL = dictionary["wallpaperURL"] as? String ?? ""
        self.wallpaperDesc = dictionary["wallpaperDesc"] as? String ?? ""
        self.wallpaperCategory = dictionary["wallpaperCategory"] as? String ?? ""
    
    }
}
