// Wallpaper-App Coded with ♥️ by Carey M

import Foundation
import UIKit
import Firebase
import SwiftEntryKit
import Lottie

class SplashViewController: UIViewController {
    
    @IBOutlet weak var phonePhoto: UIImageView!
    @IBOutlet private var animationView: LOTAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phonePhoto.layer.cornerRadius = 15
        setupAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup Lottie Animation
    func setupAnimation() {
        animationView = LOTAnimationView(name: "postcard")
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: 37.5, y: 203.5, width: 300, height: 260)
        view.addSubview(animationView)
        phonePhoto.isHidden = true
        animationView.play(completion: { (finish) in
            if finish {
                self.checkIfLoggedIn()
            } else {
                self.connectionErrorAlert()
            }
        })
    }
    
    // MARK: - Check if Logged In Function
    func checkIfLoggedIn() {
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            Defaults.setIsLoggedIn(value: true)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            self.present(feedVC, animated: true, completion: nil)
        } else {
            Defaults.setIsLoggedIn(value: false)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Attributes Wrapper
    private var attributesWrapper: EntryAttributeWrapper {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: .white)
        attributes.roundCorners = .all(radius: 10)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .darkGray, opacity: 0.5, radius: 10, offset: .zero))
        return EntryAttributeWrapper(with: attributes)
        
    }
    
    // MARK: - SwiftEntryKit Alerts
    // Notification Message
    private func showNotificationEKMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: .darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: .darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
        
    }
    
    // MARK: - Individual Alerts
    func connectionErrorAlert() {
        let connTitle = "Connection Error"
        let connDesc = "Try restarting the app by closing and reopening it"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: connTitle, desc: connDesc, textColor: UIColor.darkGray)
    }
}
