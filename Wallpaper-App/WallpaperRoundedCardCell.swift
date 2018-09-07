//  WallpaperRoundedCardCell
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import Kingfisher

class WallpaperRoundedCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var wallpaper: WallpaperCategory!
    
    func setUpCell(wallpaper: WallpaperCategory, placeholder: UIImage) {
        self.wallpaper = wallpaper
        imageView.layer.cornerRadius = 14.0
        contentView.clipsToBounds = true
        
        layer.cornerRadius = 14.0
        let config = GlidingConfig.shared
        layer.shadowOffset = config.cardShadowOffset
        layer.shadowColor = config.cardShadowColor.cgColor
        layer.shadowOpacity = config.cardShadowOpacity
        layer.shadowRadius = config.cardShadowRadius
        
        //        layer.shouldRasterize = true
        //        layer.rasterizationScale = UIScreen.main.scale
       
        if let url = URL(string: wallpaper.wallpaperURL) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder-image"))
        }
    }
}
