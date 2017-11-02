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

    var wallpaperURL: String?
    var wallpaperDesc: String!
    private var wallpaperImage: UIImage!
    
    public init(wallpaperImage: UIImage, wallpaperDesc: String) {
        self.wallpaperImage = wallpaperImage
        self.wallpaperDesc = wallpaperDesc

    }
    
    // MARK: Intializer for Wallpapers to go into Wallpapers Feed (in JSON format)
    public init(snapshot: DataSnapshot) {
        let json = JSON(snapshot.value!)
        self.wallpaperURL = json["wallpaperURL"].stringValue
        self.wallpaperDesc = json["wallpaperDesc"].stringValue
    }
    
    // MARK: - Function For Saving Wallpapers to Firebase
    func uploadWallpaper() {
        let newWallpaper =
            databaseReference.child("userUploaded").childByAutoId() //creates new folder in firebase database for useruploaded images
        let newWallpaperKey = newWallpaper.key
        
        if let wallpaperData = UIImagePNGRepresentation(self.wallpaperImage) {
            let wallpaperStorageRef = storageReference.child("images") // storage reference goes to images folder
            let newWallpaperRef = wallpaperStorageRef.child(newWallpaperKey)
            
            newWallpaperRef.putData(wallpaperData).observe(.success, handler: { (snapshot) in
                // Saving images to Firebase as Dictionary
                self.wallpaperURL = snapshot.metadata?.downloadURL()?.absoluteString
                let newWallpaperDictionary = [
                    "wallpaperURL": self.wallpaperURL,
                    "wallpaperDesc": self.wallpaperDesc
                    ]
                newWallpaper.setValue(newWallpaperDictionary)
            })
        }
        
    }
    
}
