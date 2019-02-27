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

// Custom Loading View Ext
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
struct FontName {
    static let regular = "GillSans"
    static let light = "GillSans-Light"
    static let bold = "GillSans-Bold"
    static let italic = "GillSans-Italic"
    static let semibold = "GillSans-SemiBold"
    static let semiBoldItalic = "GillSans-SemiBoldItalic"
}

extension UIFontDescriptor.AttributeName {
    static let fontUsageUIUsage = UIFontDescriptor.AttributeName(rawValue: "FontUIUsageAttribute")
}

extension UIFont {
    @objc class func gillsRegFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.regular, size: size)!
    }
    
    @objc class func gillsLightFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.light, size: size)!
    }
    
    @objc class func gillsBoldFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.bold, size: size)!
    }
    
    @objc class func gillsItalicFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.italic, size: size)!
    }
    
    @objc class func gillsSemiBoldItalicFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.semiBoldItalic, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.fontUsageUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
        }
        
        var fontName = ""
        switch fontAttribute {
        case "GillsSansRegular":
            fontName = FontName.regular
        case "GillsSansLight":
            fontName = FontName.light
        case "GillsSansBold":
            fontName = FontName.bold
        case "GillsSansItalic":
            fontName = FontName.italic
        case "GillsSansSemiBold":
            fontName = FontName.semibold
        case "GillsSansSemiBoldItalic":
            fontName = FontName.semiBoldItalic
        default:
            fontName = FontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let mySystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let myBoldSystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
            let myItalicSystemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
        
        if let initCoderMethod = class_getClassMethod(self, #selector(UIFontDescriptor.init(coder:))),
            let myInitCoderMethod = class_getClassMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}

// UINavigationBar Function Ext
extension UINavigationController {
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        setNavigationBarHidden(true, animated: true)
    }
    
    public func hideTransparentNavigationBar() {
        setNavigationBarHidden(true, animated: false)
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: .default), for: .default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
}

// Custom Back Button Ext
extension UIViewController {
    
    func customBackBtn() {
        let customBackBtnLeft: UIButton = UIButton()
        let image = UIImage(named: "light-back-button")
        customBackBtnLeft.setImage(image, for: .normal)
        customBackBtnLeft.setTitle(nil, for: .normal)
        customBackBtnLeft.sizeToFit()
        customBackBtnLeft.addTarget(self, action: #selector(customBackBtnAction), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: customBackBtnLeft)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func customBackBtnAction(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// Sketch Shadow Blur
extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

// String Extension for Handling isEmpty
extension String {
    var isNotEmpty: Bool {
        get {
            return !isEmpty
        }
    }
}

// MARK: - TextFields/UIView Shake
extension UIView {
    static func shake(view: UIView, for duration: TimeInterval = 0.5, withTranslation translation: CGFloat = 10) {
        let propertyAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.3) {
            view.layer.borderColor = redColor.cgColor
            view.layer.borderWidth = 1
            view.transform = CGAffineTransform(translationX: translation, y: 0)
        }
        
        propertyAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.2)
        
        propertyAnimator.addCompletion { (_) in
            view.layer.borderWidth = 0
        }
        
        propertyAnimator.startAnimation()
    }
}

// MARK: - Smart Invert Colors (Dark Mode Images)
extension UIView {
    @IBInspectable var ignoresInvertColors: Bool {
        get {
            if #available(iOS 11.0, *) {
                return accessibilityIgnoresInvertColors
            }
            return false
        }
        set {
            if #available(iOS 11.0, *) {
                accessibilityIgnoresInvertColors = newValue
            }
        }
    }
}