//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase

class SplashViewController: UIViewController {
    
    @IBOutlet weak var phonePhoto: UIImageView!
    
    var splashTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loading(.start)
        splashTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(SplashViewController.checkIfLoggedIn), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfLoggedIn()
    }
    
    @objc func checkIfLoggedIn() {
        if authRef.currentUser != nil && authRef.currentUser?.isAnonymous != nil {
            Defaults.setIsLoggedIn(value: true)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            self.present(feedVC, animated: true, completion: nil)
            self.splashTimer.invalidate()
        } else {
            Defaults.setIsLoggedIn(value: false)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            self.splashTimer.invalidate()
        }
    }
}
