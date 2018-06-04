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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfLoggedIn()
    }
    
    func setupTwinkle() {
        Twinkle.twinkle(phonePhoto)
    }
    
    func checkIfLoggedIn() {
        if Auth.auth().currentUser != nil {
            UserDefaults.standard.setIsLoggedIn(value: true)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            UIApplication.topViewController()?.present(feedVC, animated: true, completion: nil)
            print(Auth.auth().currentUser!)
        } else {
            UserDefaults.standard.setIsLoggedIn(value: false)
            self.loading(.stop)
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                as! LoginViewController
            UIApplication.topViewController()?.present(loginVC, animated: true, completion: nil)
        }
    }
}
