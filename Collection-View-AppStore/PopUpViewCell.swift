//
//  PopUpViewCell.swift
//  Wallpaper-App
//
//  Created by Carey M on 5/11/18.
//  Copyright © 2018 C McGhee. All rights reserved.
//

import UIKit
import EasyTransitions

class PopUpViewCell: UICollectionViewCell, NibLoadableView {
    
    @IBOutlet weak var cardView: CardView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        set(shadowStyle: .todayCard)
    }
}
