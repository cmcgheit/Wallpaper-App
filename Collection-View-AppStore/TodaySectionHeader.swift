//
//  TodaySectionHeader.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/23/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit

class TodaySectionHeader: UICollectionReusableView {

   internal static let viewHeight: CGFloat = 81
    
    // MARK: - Factory Method
    
    internal static func dequeue(fromCollectionView collectionView: UICollectionView, ofKind kind: String, atIndexPath indexPath: IndexPath) -> TodaySectionHeader {
        guard let view: TodaySectionHeader = collectionView.dequeueSupplementaryView(kind: kind, indexPath: indexPath) else {
            fatalError("*** Failed to dequeue TodaySectionHeader ***")
        }
        return view
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
}
