//SignUpViewController.swift, coded with love by C McGhee

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpTxtFld: AnimatedTextField!
    @IBOutlet weak var signUpPassFld: AnimatedTextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        guard let email = signUpTxtFld.text else { return }
        guard let pass = signUpPassFld.text else { return }
        if email != "" || pass != "" {
            // MARK: - No Email/Password/Age entered Alert (not registered)
            //
        } else { // Register New User
            AuthService.instance.registerUser(withEmail: email, andPassword: pass, userCreationComplete: { (success, registrationError) in
                if success { // After registered, login the user
                    AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, nil) in
                        self.performSegue(withIdentifier: "toFeedViewController", sender: self) // Take user to Feed once sucessfully signed in
                        print("Successfully registered/Signed-In user")
                    })
                } else {
                    print(String(describing: registrationError?.localizedDescription))
                }
            })
        }
    }
}
