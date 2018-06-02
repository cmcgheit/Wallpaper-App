//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation
import UIKit
import Firebase
import Twinkle

class SplashViewController: UIViewController {
    
    @IBOutlet weak var phonePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTwinkle()
        self.loading(.start) // show loading indicator when showing twinkle
        checkIfLoggedIn()
    }
    
    func checkIfLoggedIn() {
        if Auth.auth().currentUser != nil {
            UserDefaults.standard.setIsLoggedIn(value: true)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController")
            self.loading(.stop)
            self.present(feedVC, animated: true, completion: nil)
        } else {
            UserDefaults.standard.setIsLoggedIn(value: false)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.loading(.stop)
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    func setupTwinkle() {
        Twinkle.twinkle(phonePhoto)
    }
}
