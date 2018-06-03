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
        if Auth.auth().currentUser?.uid != nil {
            UserDefaults.standard.setIsLoggedIn(value: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let feedVC = storyboard.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
            self.loading(.stop)
            self.present(feedVC, animated: true, completion: nil)
        } else {
            UserDefaults.standard.setIsLoggedIn(value: false)
            self.performSegue(withIdentifier: "toLoginViewController", sender: self)
            self.loading(.stop)
        }
    }
    
    func setupTwinkle() {
        Twinkle.twinkle(phonePhoto)
    }
}
