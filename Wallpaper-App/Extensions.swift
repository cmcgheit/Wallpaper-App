//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit

// Firebase images Extensions
extension Data {
    func getImageFromData() -> UIImage? {
        if let img = UIImage(data: self) {
            return img
        } else {
            return nil
        }
    }
}

extension UIImage {
    func prepareImageForSaving() -> Data? {
        if let img = UIImagePNGRepresentation(self) {
            return img
        } else {
            return nil
        }
    }
}

// Loading Ext
enum LoadingState {
    case start
    case stop
}

extension UIViewController {
    func loading(_ state: LoadingState) {
        if state == .start {
            CustomLoadingView.shared.startLoading(view)
        } else {
            CustomLoadingView.shared.stopLoading()
        }
    }
}

// Top View Controller Ext
extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}

// Font
enum FontName: String {
    case regular = "GillsSans"
    case light = "GillsSans-Light"
    case bold = "GillSans-Bold"
    case italic = "GillsSans-Italic"
    case semibold = "GillsSans-SemiBold"
    case semiBoldItalic = "GillsSans-SemiBoldItalic"
}

enum FontSize: CGFloat {
    case size = 15
}

extension UIFont {
    class var regularFont15: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: FontSize.size.rawValue)!
    }
}
