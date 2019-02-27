//Wallpaper-App Coded with ♥️ by Carey M 

import UIKit

var imageCache = [String: UIImage]()

class ImageViewCache: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch wallpaper images:", error)
                return
            }
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let wallpaperData = data else { return }
            
            let wallpaperImage = UIImage(data: wallpaperData)
            
            imageCache[url.absoluteString] = wallpaperImage
            
            DispatchQueue.main.async {
                self.image = wallpaperImage
            }
        }.resume()
    }
}
