//Created with ♥️ by: Carey M 

import UIKit

public struct WallpaperItem {
    let title: String
    let header: String
    let desc: String
    let image: UIImage
    
    func highlightedImage() -> WallpaperItem {
            let scaledImage = image.resize(toWidth: image.size.width * Constants.cardHighlightedFactor)
            return WallpaperItem(title: title,
                                        header: header,
                                        desc: desc,
                                        image: scaledImage)
        }
}


