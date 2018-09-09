//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase
import Twinkle

class SplashViewController: UIViewController {
    
    @IBOutlet weak var phonePhoto: UIImageView!
    
    var splashTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loading(.start) // show loading indicator when showing twinkle
        splashTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(SplashViewController.checkIfLoggedIn), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupTwinkle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfLoggedIn()
    }
    
    func setupTwinkle() {
        Twinkle.twinkle(phonePhoto)
    }
    
    @objc func checkIfLoggedIn() {
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            UserDefaults.standard.setIsLoggedIn(value: true)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            self.present(feedVC, animated: true, completion: nil)
            self.splashTimer.invalidate()
        } else {
            UserDefaults.standard.setIsLoggedIn(value: false)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            self.splashTimer.invalidate()
        }
    }
}
