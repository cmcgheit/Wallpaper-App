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

// UIWindow Ext
public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(viewC: self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(viewC: UIViewController?) -> UIViewController? {
        if let naviVC = viewC as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(viewC: naviVC.visibleViewController)
        } else if let tabbarVC = viewC as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(viewC: tabbarVC.selectedViewController)
        } else {
            if let presentedVC = viewC?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(viewC: presentedVC)
            } else {
                return viewC
            }
        }
    }
}

// Font
enum FontName: String {
    case regular = "GillsSans.ttf"
    case light = "GillsSans-Light.ttf"
    case bold = "GillSans-Bold.ttf"
    case italic = "GillsSans-Italic.ttf"
    case semibold = "GillsSans-SemiBold.ttf"
    case semiBoldItalic = "GillsSans-SemiBoldItalic.ttf"
}

extension UIFont {
    class var regularFont15: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 15)!
    }
    
    class var regularFont17: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 17)!
    }
    
    class var regularFont20: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 20)!
    }
    
    class var boldFont20: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 20)!
    }
    
    class var boldItalic17: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 17)!
    }
    
    class var semiBold17: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 17)!
    }
    
    class var semiBoldItalic20: UIFont {
        return UIFont(name: FontName.regular.rawValue, size: 20)!
    }
}
