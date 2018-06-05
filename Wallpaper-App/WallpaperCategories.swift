//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation

var wallpaperCatList: [WallpaperCategories] = [.Sports, .Music, .Art] // don't need

enum WallpaperCategories: String {
    case Sports, Music, Art
} // don't need

struct WallpaperCategory {
    let name: String
    var data: [[String:Any]]
    
    init(name: String, data: [[String:Any]]) {
        self.name = name
        self.data = data
    }
}
