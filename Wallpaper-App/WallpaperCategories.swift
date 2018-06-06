//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase

var wallpaperCatList: [WallpaperCategories] = [.Sports, .Music, .Art] // don't need

enum WallpaperCategories: String {
    case Sports, Music, Art
} // don't need

struct WallpaperCategory: Codable {
    var catName: String
    var wallpaperURL: String
    var wallpaperDesc: String
    // var wallpaperCatImage: UIImage // save image?
    
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
