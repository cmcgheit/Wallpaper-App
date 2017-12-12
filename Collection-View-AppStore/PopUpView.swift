//
//  PopUpView.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 11/1/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import Firebase

class PopUpView: UIView {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var wallpaperDescLbl: UILabel!
    @IBOutlet weak var wallpaperPopImage: UIImageView!
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PopUpView", owner: self, options: nil)
        addSubview(popUpView)
        popUpView.frame = self.bounds
        popUpView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    
  // MARK: Downloading Wallpaper for PopUpView
        var wallpaper: Wallpaper! {
            didSet {
                wallpaperPopImage.layer.cornerRadius = 14.0
                self.wallpaperDescLbl.text = wallpaper.wallpaperDesc
                
                // MARK: - Download Images FROM Firebase Function
                func downloadImageFromFirebase() {
                    if let wallpaperURL = wallpaper.wallpaperURL {
                        let wallpaperStorageRef = Storage.storage().reference(forURL: wallpaperURL)
                        wallpaperStorageRef.getData(maxSize: 2 * 1024 * 1024, completion: { [weak self] (data, error) in
                            if let error = error {
                                print("Error downloading Wallpapers: \(error)")
                            } else {
                                if let wallpaperData = data {
                                    DispatchQueue.main.async {
                                        let image = UIImage(data: wallpaperData)
                                        self?.wallpaperPopImage.image = image
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }



