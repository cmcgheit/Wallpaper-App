//  WallpaperRoundedCardCell
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import GlidingCollection
import Kingfisher
import EasyTransitions

internal class WallpaperRoundedCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardView: CardView!
    
    var wallpaper: WallpaperCategory!
    
    func setUpCell(wallpaper: WallpaperCategory) {
        self.wallpaper = wallpaper
        imageView.layer.cornerRadius = 14.0
        contentView.clipsToBounds = true
        
        let config = GlidingConfig.shared
        imageView.layer.shadowOffset = config.cardShadowOffset
        imageView.layer.shadowColor = config.cardShadowColor.cgColor
        imageView.layer.shadowOpacity = config.cardShadowOpacity
        imageView.layer.shadowRadius = config.cardShadowRadius
       
        if let url = URL(string: wallpaper.wallpaperURL) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder-image"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        set(shadowStyle: .todayCard)
    }
}
