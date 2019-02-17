// Wallpaper-App Coded with ♥️ by Carey M

import UIKit
import SwiftEntryKit

extension UIViewController {
    
    // MARK: - Attributes Wrapper
    var attributesWrapper: EntryAttributeWrapper {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: .white)
        attributes.roundCorners = .all(radius: 15)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .darkGray, opacity: 0.5, radius: 15, offset: .init(width: 0, height: 3)))
        attributes.displayDuration = 3 // longer duration than default for photo lib alert
        return EntryAttributeWrapper(with: attributes)
        
    }
    
    // MARK: - SwiftEntryKit Alerts
    // Alert Notification
    func showNotificationEKMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
        
    }
    
    // Top Banner Message
    func showBannerNotificationMessage(attributes: EKAttributes, text: String, desc: String, textColor: UIColor) {
        let text = EKProperty.LabelContent(text: text, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 15), color: .darkGray))
        let simpleMessage = EKSimpleMessage(title: text, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
