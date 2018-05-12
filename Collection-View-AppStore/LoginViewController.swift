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
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
        guard let email = emailTextFld.text else{return}
        guard let pass = passTextFld.text else{return}
        
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error == nil && user != nil{
                // success
                self.performSegue(withIdentifier: "toFeedViewController", sender: nil)
            } else {
                print("Error Log In:\(error!.localizedDescription)")
            }
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
}
