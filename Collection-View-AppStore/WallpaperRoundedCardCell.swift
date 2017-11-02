//
//  WallpaperRoundedCardCell
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import Firebase

internal class WallpaperRoundedCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var wallpaper: Wallpaper! {
        didSet {
            imageView.layer.cornerRadius = 14.0
            
                if let wallpaperURL = wallpaper.wallpaperURL {
                    let wallpaperStorageRef = Storage.storage().reference(forURL: wallpaperURL)
                    wallpaperStorageRef.getData(maxSize: 2 * 1024 * 1024, completion: { [weak self] (data, error) in
                        if let error = error {
                            print("Error downloading Wallpapers: \(error)")
                        } else {
                            if let wallpaperData = data {
                                DispatchQueue.main.async {
                                    let image = UIImage(data: wallpaperData)
                                    self?.imageView.image = image
                                }
                            }
                        }
                    })
                }
            }
        }
    }
