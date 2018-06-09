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
        var config = GlidingConfig.shared
        layer.shadowOffset = config.cardShadowOffset
        layer.shadowColor = config.cardShadowColor.cgColor
        layer.shadowOpacity = config.cardShadowOpacity
        layer.shadowRadius = config.cardShadowRadius
        config.buttonsFont = UIFont.regularFont15
        config.inactiveButtonsColor = config.activeButtonColor
        
        if let url = URL(string: wallpaper.wallpaperURL) {
            imageView.kf.setImage(with: url) // add placeholder?
        }
    }
}
