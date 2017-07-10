//
//  Reusable.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 6/25/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit

/// Represents a UIView that is a reuseable view such as a
/// UITableViewCell, UITableViewHeaderFooterView or UICollectionViewCell.
/// Provides everything necessary for a reusable view to be reused.
internal protocol Reusable: class {
    
    /// Identifier used to dequeue this view for reuse.
    static var reuseIdentifier: String { get }
    
    /// UINib containing the Interface Builder representation.
    static var nib: UINib? { get }
}

/// Provides default implementations of the necessary variables
/// to reuse a generic view.
internal extension Reusable {
    
    /// Uses the object's Type name as the ReuseIdentifier.
    static var reuseIdentifier: String { return String(describing: self) }
    
    /// Uses the UINib named after the object's type name.
    static var nib: UINib? { return UINib(nibName: String(describing: self), bundle: nil) }
}

/// Declares that all UICollectionReusableViews conform to the
/// Reusable protocol and therefore gain the default
/// implementation without any additional effort.
extension UICollectionReusableView: Reusable { }

/// Provides default implementations of generic reuse methods on UICollectionView to
/// allow for consumers to register reuseable views for reuse such as UICollectionViewCells.
internal extension UICollectionView {
    
    /// Registers a UICollectionViewCell subclass for reuse, by
    /// registering a UINib or Type for the object's reuseIdentifier.
    ///
    /// - Parameter _: UICollectionViewCell to register for reuse.
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func registerSupplementaryView<T: UICollectionReusableView>(_ : T.Type, kind: String) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    /// Dequeues a UICollectionViewCell for reuse given a specific indexPath.
    ///
    /// - Parameter indexPath: indexPath to dequeue cell for
    /// - Returns: a reused UICollectionViewCell associated with the indexPath
    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T? where T: Reusable {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T
    }
    
    func dequeueSupplementaryView<T: UICollectionReusableView>(kind: String, indexPath: IndexPath) -> T? where T: Reusable {
        return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T
    }
    
}


