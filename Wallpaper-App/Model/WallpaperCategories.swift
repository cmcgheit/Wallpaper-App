//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase

struct WallpaperCategory: Codable {
    var catName: String
    var wallpaperURL: String
    var wallpaperDesc: String
    // private var wallpaperCatImage: UIImage // save image?
    
    init(catName: String, wallpaperURL: String, wallpaperDesc: String) {
        self.catName = catName
        self.wallpaperURL = wallpaperURL
        self.wallpaperDesc = wallpaperDesc
    }
    
    init?(snapshot: DataSnapshot) {
        guard let catDict = snapshot.value as? [String: Any] else { return nil }
        self.catName = catDict["wallpaperCategory"]  as? String ?? ""
        self.wallpaperURL = catDict["wallpaperURL"] as? String ?? ""
        self.wallpaperDesc = catDict["wallpaperDesc"] as? String ?? ""
        
        func toAnyObj() -> [String: Any] {
            return ["wallpaperCategory": catName,
                    "wallpaperURL": wallpaperURL,
                    "wallpaperDesc": wallpaperDesc]
        }
    }
}

struct WallpaperCategories {
    let catName: String
    let wallpaperData: [WallpaperCategory]
}

