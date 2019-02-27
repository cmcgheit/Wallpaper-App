//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit

protocol DynamicTypeAccessibilityLayout {
    var fontSizeStandardRangeConstraints: [NSLayoutConstraint] { get set }
    var fontSizeAccessibilityRangeConstraints: [NSLayoutConstraint] { get set }
}

extension DynamicTypeAccessibilityLayout {
    private func adjustConstraints(with isAccessibilityCategory: Bool) {
        if isAccessibilityCategory {
            NSLayoutConstraint.deactivate(fontSizeStandardRangeConstraints)
            NSLayoutConstraint.activate(fontSizeAccessibilityRangeConstraints)
        } else {
            NSLayoutConstraint.deactivate(fontSizeAccessibilityRangeConstraints)
            NSLayoutConstraint.activate(fontSizeStandardRangeConstraints)
        }
    }
    
    @available(iOS 11.0, *)
    func adjustDynamicTypeLayout(traitCollection: UITraitCollection) {
        adjustConstraints(with: traitCollection.preferredContentSizeCategory.isAccessibilityCategory)
    }
    
    @available(iOS 11.0, *)
    func adjustDynamicTypeLayout(traitCollection: UITraitCollection, previousTraitCollection: UITraitCollection?) {
        guard let previousContentSizeCategory = previousTraitCollection?.preferredContentSizeCategory else {
            return
        }
        
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        
        if previousContentSizeCategory.isAccessibilityCategory != isAccessibilityCategory {
            adjustConstraints(with: isAccessibilityCategory)
        }
    }
}
