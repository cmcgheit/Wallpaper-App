//  WallpaperRoundedCardCell
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase

internal class WallpaperRoundedCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var wallpaper: Wallpaper! {
        didSet {
            imageView.layer.cornerRadius = 14.0
        }
    }
}
