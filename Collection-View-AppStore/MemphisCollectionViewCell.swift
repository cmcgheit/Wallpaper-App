//
//  MemphisCollectionViewCell.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import CoreMotion

internal class MemphisCollectionViewCell: BaseRoundedCardCell {

    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Factory Method
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> MemphisCollectionViewCell {
        guard let cell: MemphisCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath) else {
            fatalError("*** Failed to dequeue Memphis Cell ***")
        }
        return cell
    }
    
override func awakeFromNib() {
    super.awakeFromNib()
    
    imageView.layer.cornerRadius = 14.0
    
}

}



