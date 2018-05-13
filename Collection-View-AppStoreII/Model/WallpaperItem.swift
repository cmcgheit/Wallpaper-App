//Created with ♥️ by: Carey M 

import Foundation

public struct WallpaperItem {
    var title: String
    var imageName: String
    
    private init(title: String, imageName: String) {
        self.title = title
        self.imageName = imageName
    }
    
    public static let all: [WallpaperItem] = [
        WallpaperItem(title: "Chicago", imageName: "chicagobasketball"),
        WallpaperItem(title: "Philadelphia", imageName: "philabasketball"),
        WallpaperItem(title: "DC", imageName: "dcbasketball"),
        WallpaperItem(title: "Memphis", imageName: "memphislong"),
        WallpaperItem(title: "Minnesota", imageName: "minnelong"),
        WallpaperItem(title: "Golden State", imageName: "goldenstatelong"),
        WallpaperItem(title: "Utah", imageName: "utahlong"),
        WallpaperItem(title: "Toronto", imageName: "torontolong"),
        WallpaperItem(title: "San Antonio", imageName: "sanantoniolong"),
        WallpaperItem(title: "Cleveland", imageName: "clevelandbasketball")
    ]
}
