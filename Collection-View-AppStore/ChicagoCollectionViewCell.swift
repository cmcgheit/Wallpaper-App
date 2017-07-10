//
//  ChicagoCollectionViewCell.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import CoreMotion

internal class ChicagoCollectionViewCell: BaseRoundedCardCell {

    
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Factory Method
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> ChicagoCollectionViewCell {
        guard let cell: ChicagoCollectionViewCell = collectionView.dequeueReusableCell(indexPath: indexPath) else {
            fatalError("*** Failed to dequeue Chicago Cell ***")
        }
        return cell
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 14.0
        
    }
    
}

