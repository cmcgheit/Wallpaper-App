//PopUpViewController.swift, created with love by C McGhee

import Foundation
import UIKit
import Firebase
import EasyTransitions

class PopUpViewController: UIVIewController {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    
    init() {
        super.init(nibName: String(describing: AppDetailViewController.self),
                   bundle: Bundle(for: AppDetailViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.delegate = self
        backView.set(shadowStyle: .todayCard)
        layout(presenting: false)
        if #available(iOS 11, *) {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func layout(presenting: Bool) {
        let cardLayout: CardView.Layout = presenting ? .expanded : .collapsed
        contentView.layer.cornerRadius = cardLayout.cornerRadius
        backView.layer.cornerRadius = cardLayout.cornerRadius
        cardView.set(layout: cardLayout)
    }
}

// MARK: Downloading Wallpaper for PopUp
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

extension PopUpViewController: CardViewDelegate {
    func closeCardView() {
        dismiss(animated: true, completion: nil)
    }
}

