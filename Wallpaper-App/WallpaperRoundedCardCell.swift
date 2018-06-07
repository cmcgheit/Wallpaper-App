//  WallpaperRoundedCardCell
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import Kingfisher

internal class WallpaperRoundedCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setUpCell(wallpaper: WallpaperCategory) {
        //self.wallpaper = wallpaper
        imageView.layer.cornerRadius = 14.0
        contentView.clipsToBounds = true
        layer.shadowOffset = GlidingConfig.shared.cardShadowOffset
        layer.shadowColor = GlidingConfig.shared.cardShadowColor.cgColor
        layer.shadowOpacity = GlidingConfig.shared.cardShadowOpacity
        layer.shadowRadius = GlidingConfig.shared.cardShadowRadius
        
        if let url = URL(string: wallpaper.wallpaperURL) {
            imageView.kf.setImage(with: url) // add placeholder?
        }
    }
}
