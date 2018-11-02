//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase
import Lottie

class SplashViewController: UIViewController {
    
    @IBOutlet weak var phonePhoto: UIImageView!
    @IBOutlet private var animationView: LOTAnimationView!

    var splashTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loading(.start)
        splashTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(SplashViewController.checkIfLoggedIn), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        phonePhoto.isHidden = true
        setupAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfLoggedIn()
    }
    
    func setupAnimation() {
        animationView = LOTAnimationView(name: "postcard")
        animationView.play()
        phonePhoto.isHidden = true
    }
    
    @objc func checkIfLoggedIn() {
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            Defaults.setIsLoggedIn(value: true)
            self.loading(.stop)
            self.animationView.stop()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            self.present(feedVC, animated: true, completion: nil)
            self.splashTimer.invalidate()
        } else {
            Defaults.setIsLoggedIn(value: false)
            self.loading(.stop)
            self.animationView.stop()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            self.splashTimer.invalidate()
        }
    }
}
