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
        guard let email = signUpTxtFld.text  else {return}
        guard let pass = signUpPassFld.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
            if error == nil  && user != nil {
                // success
                self.performSegue(withIdentifier: "goToLoginViewController", sender: self)
            } else {
                print("Error Log In:\(error!.localizedDescription)")
            }
        }
    }
}
