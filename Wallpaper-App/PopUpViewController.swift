//PopUpViewController.swift, coded with love by C McGhee

import Foundation
import UIKit
import Firebase
import EasyTransitions

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var wallpaperPopImage: UIImageView!
    @IBOutlet weak var wallpaperDescLbl: UILabel!
    
    var wallpaper: [WallpaperCategory] = []
    var selectedIndex: IndexPath!
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.delegate = self
        // backView.set(shadowStyle: .todayCard)
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

extension PopUpViewController: CardViewDelegate {
    func closeCardView() {
        dismiss(animated: true, completion: nil)
    }
}

