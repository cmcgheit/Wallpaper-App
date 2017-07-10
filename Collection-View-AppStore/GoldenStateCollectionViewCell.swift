
//
//  GoldenStateCollectionViewCell.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import CoreMotion

internal class GoldenStateCollectionViewCell: BaseRoundedCardCell {

    @IBOutlet private weak var imageView: UIImageView!
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> GoldenStateCollectionViewCell {
        guard let cell: GoldenStateCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath) else {
            fatalError("*** Failed to dequeue Golden State Cell  ***")
        }
        return cell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()


    imageView.layer.cornerRadius = 14.0
   
   
}

}

