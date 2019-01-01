//
//  CardContentView.swift
//  AppStoreHomeInteractiveTransition
//
//  Created by Wirawit Rueopas on 3/4/2561 BE.
//  Copyright © 2561 Wirawit Rueopas. All rights reserved.
//

import UIKit

@IBDesignable final class CardContentView: UIView, NibLoadable {
    
    var viewModel: WallpaperItem? {
        didSet {
            titleLabel.text = viewModel?.title
            headerLabel.text = viewModel?.header
            descLabel.text = viewModel?.desc
            imageView.image = viewModel?.image
        }
    }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var descLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet weak var imageToTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageToLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageToTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageToBottomAnchor: NSLayoutConstraint!
    
    @IBInspectable var backgroundImage: UIImage? {
        get {
            return self.imageView.image
        }
        
        set(image) {
            self.imageView.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        commonSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        commonSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    private func commonSetup() {
        // *Make the background image stays still at the center while we animationg,
        // else the image will get resized during animation.
        imageView.contentMode = .center
        setFontState(isHighlighted: false)
    }
    
    // This "connects" highlighted (pressedDown) font's sizes with the destination card's font sizes
    func setFontState(isHighlighted: Bool) {
        if isHighlighted {
            titleLabel.font = UIFont.systemFont(ofSize: 36 * Constants.cardHighlightedFactor, weight: .bold)
            headerLabel.font = UIFont.systemFont(ofSize: 18 * Constants.cardHighlightedFactor, weight: .semibold)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
            headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
    }
}
