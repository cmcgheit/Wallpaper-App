//
//  LoginViewController.swift
//  Collection-View-AppStore
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.
//

import UIKit
import Firebase
//import Facebook

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginCardView: UIView!
    @IBOutlet weak var emailTextFld: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var passTextFld: UITextField!
    @IBOutlet weak var facebookLoginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signInBtnPressed(_ sender: UIButton) {
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
    
    @IBAction func facebookLoginBtnPressed(_sender: UIButton) {
        
    }
    
    
}
