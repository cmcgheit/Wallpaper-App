// Wallpaper-App Coded with ♥️ by Carey M

import Foundation
import UIKit
import Firebase
import SwiftEntryKit
import Lottie

class SplashViewController: UIViewController {
    
    @IBOutlet fileprivate var phonePhoto: UIImageView!
    @IBOutlet fileprivate var animationView: LOTAnimationView!
    
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
    
    // MARK: - Individual Alerts
    func connectionErrorAlert() {
        let connTitle = "Connection Error"
        let connDesc = "Try restarting the app by closing and reopening it"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: connTitle, desc: connDesc, textColor: UIColor.darkGray)
    }
}
