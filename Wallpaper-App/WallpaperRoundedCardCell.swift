//  WallpaperRoundedCardCell
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import Kingfisher

internal class WallpaperRoundedCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var wallpaper: WallpaperCategory!
    
    func setUpCell(wallpaper: WallpaperCategory) {
        self.wallpaper = wallpaper
        imageView.layer.cornerRadius = 14.0
        if #available(iOS 11.0, *) {
            imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }
        contentView.clipsToBounds = true
        
        let config = GlidingConfig.shared
        imageView.layer.backgroundColor = UIColor.clear.cgColor
        imageView.layer.shadowOffset = config.cardShadowOffset
        imageView.layer.shadowColor = config.cardShadowColor.cgColor
        imageView.layer.shadowOpacity = config.cardShadowOpacity
        imageView.layer.shadowRadius = config.cardShadowRadius
        
        //        layer.shouldRasterize = true
        //        layer.rasterizationScale = UIScreen.main.scale
       
        if let url = URL(string: wallpaper.wallpaperURL) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder-image"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
