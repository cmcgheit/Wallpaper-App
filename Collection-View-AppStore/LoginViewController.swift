//  LoginViewController.swift
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginCardView: UIView!
    @IBOutlet weak var emailTextFld: AnimatedTextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var passTextFld: AnimatedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Take user to Feed if already logged-in
        if (Auth.auth().currentUser?.uid != nil)  {
            UserDefaults.standard.setIsLoggedIn(value: true)
            self.performSegue(withIdentifier:  "toFeedViewController", sender: self)
        } else {
            // If User not logged in
            do {
                try Auth.auth().signOut()
                return
            } catch  {
                print(error)
            }
            UserDefaults.standard.setIsLoggedIn(value: false)
        }
    }
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
        guard let email = emailTextFld.text else { return }
        guard let pass = passTextFld.text else { return }
        if email != "" || pass != ""  {
            // MARK: - No Email/Password entered Alert (not registered)
            
        } else {
            // MARK: - Login User Successfully
            AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, loginError) in
                if success {
                    // self.completeSignIn(id: (Auth.auth().currentUser?.uid)!) // collects uid/keychain when user signs in
                    UserDefaults.standard.setIsLoggedIn(value: true)
                    self.performSegue(withIdentifier:
                        "toFeedViewController", sender: nil)
                } else {
                    // MARK: - Incorrect Email/Password Alert
                    // Auth.auth().sendPasswordReset(withEmail: email)
                    print(String(describing: loginError?.localizedDescription))
                    // Take User to SignUp if not a registered user
                }
            })
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUpViewController", sender: nil)
    }
    
    @IBAction func loginAnonymousBtnClicked(_ sender: Any) {
        // Auth user
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error == nil {
                // successful Anonymous login, segue to FeedViewController
                self.performSegue(withIdentifier: "toFeedViewController", sender: nil)
            }
        }
    )}
    
    // MARK: - Dismiss Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //// MARK: KeyChain Wrapper Function - storing user data
    //func completeSignIn(id: String) {
    //    let saveSuccessful: Bool = KeychainWrapper.standard.set(id, forKey: KEY_UID)
    //    print("Keychain Status: \(saveSuccessful)")
    //    // Take student to StudentVC once stored keychain wrapper
    //    performSegue(withIdentifier: SegueIdentifier.toStudentVC.rawValue, sender: self)
    //}
}


