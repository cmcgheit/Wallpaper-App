//
//  Wallpaper.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

let databaseReference = Database.database().reference()
let storageReference = Storage.storage().reference()

class Wallpaper {
    
    let wallpaperCatTitles = ["Sports", "Music", "Art"]
    
    var wallpaperURL: String?
    var wallpaperDesc: String!
    var wallpaperCategory: String!
    private var wallpaperImage: UIImage!
    
    public init(wallpaperImage: UIImage, wallpaperDesc: String, wallpaperCategory: String) {
        self.wallpaperCategory = wallpaperCategory
        self.wallpaperImage = wallpaperImage
        self.wallpaperDesc = wallpaperDesc
        
    }
    
    // MARK: Intializer for Wallpapers to go into Wallpapers Feed (turn into JSON format)
    public init(snapshot: DataSnapshot) {
        let json = JSON(snapshot.value!)
        self.wallpaperURL = json["wallpaperURL"].stringValue
        self.wallpaperDesc = json["wallpaperDesc"].stringValue
        self.wallpaperCategory = json["wallpaperCategory"].stringValue
        
    }
    
    // MARK: - Function for uploading Wallpapers to Firebase
    func uploadWallpaper() {
        let newWallRef = databaseReference.child("wallpapers").childByAutoId() // Puts uploaded wallpaper images in database under "wallpapers"
        let newWallKey = newWallRef.key
        
        if let wallpaperData = UIImagePNGRepresentation(self.wallpaperImage) {
            let wallpaperStorageRef = Storage.storage().reference().child("images") // saves image to storage under "images", later assign category
            let newWallpaperImageRef = wallpaperStorageRef.child(newWallKey)
            
            newWallpaperImageRef.putData(wallpaperData).observe(.success, handler: { (snapshot) in
                self.wallpaperURL = snapshot.metadata?.downloadURL()?.absoluteString
                let newWallpaperDictionary = [ // creates dictionary of wallpaper info: url, category, desc
                    "wallpaperURL": self.wallpaperURL,
                    "wallpaperCategory": self.wallpaperCategory,
                    "wallpaperDesc": self.wallpaperDesc
                ]
                newWallRef.setValue(newWallpaperDictionary)
            })
        }
    }
    
}
