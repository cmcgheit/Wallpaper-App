//  LoginViewController.swift
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import SwiftEntryKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet fileprivate var loginCardView: CustomCardView!
    @IBOutlet fileprivate var emailTextFld: UITextField!
    @IBOutlet fileprivate var passTextFld: RevealPasswordTextField!
    @IBOutlet fileprivate var signInBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var signUpBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var loginAnBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var forgotInfoBtn: RoundedRectBlueButton!
    
    // Restore text
    var defaultsKey: String = ""
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        customBackBtn()
        
        emailTextFld.delegate = self
        passTextFld.delegate = self
        
        signInBtn.layer.cornerRadius = 15
        signUpBtn.layer.cornerRadius = 15
        loginAnBtn.layer.cornerRadius = 15
        forgotInfoBtn.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificationObservers()
        
        // Take user to Feed if already logged-in
        if Reachability.isConnectedToNetwork() {
            if authRef.currentUser?.uid != nil && authRef.currentUser?.isAnonymous != nil {
                Defaults.setIsLoggedIn(value: true)
                let feedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
                self.present(feedVC, animated:true)
            } else {
                // If User not logged in
                do {
                    try authRef.signOut()
                    return
                } catch  {
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                    print(error)
                }
                Defaults.setIsLoggedIn(value: false)
            }
        } else {
            noNetworkAlert()
            Defaults.setIsLoggedIn(value: false)
            removeToken() // don't set token if not logged in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotifications()
    }
    
    // MARK: - Notifications
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: .keyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: .keyboardWillHide, object: nil)
        
        emailTextFld.addTarget(self, action: #selector(saveToUserDefaults(_:)), for: .editingDidEnd)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(keyboardWillShow)
        NotificationCenter.default.removeObserver(keyboardWillHide)
        // NotificationCenter.default.removeObserver(saveToUserDefaults) need?
    }
    
    // MARK: - Individual Alerts
    func successfulLoginAlert() {
        let successTitleText =  "Successfully Signed In"
        let successDescText = "Taking you to the feed"
        showBannerNotificationMessage(attributes: attributesWrapper.attributes, text: successTitleText, desc: successDescText, textColor: .darkGray)
    }
    
    func noEmailPassAlert() {
        let noEmailTitleText = "User Not Registered"
        let noEmailDescText = "No email and/or password entered, please enter an email or password and login"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: noEmailTitleText, desc: noEmailDescText, textColor: .darkGray)
    }

    func noNetworkAlert() {
        let noNetworkTitle = "No Network Connection"
        let noNetworkDesc = "Please check your network connection, then close and restart the app"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: noNetworkTitle, desc: noNetworkDesc, textColor: .darkGray)
    }
    
    func anonyLoginError() {
        let anonyErrorTitle = "Anonymous Login Error"
        let anonyErrorDesc = "Check your network connection, restart the app and try to login anonymously again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: anonyErrorTitle, desc: anonyErrorDesc, textColor: .darkGray)
    }
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        guard let email = emailTextFld.text, email.isNotEmpty else { return }
        guard let pass = passTextFld.text, pass.isNotEmpty else { return }
        
        if email.isEmpty || pass.isEmpty {
            UIView.shake(view: emailTextFld)
            UIView.shake(view: passTextFld)
            noEmailPassAlert()
        } else if email.count > 0 && pass.count > 0 {
            authenticateUser(withEmail: email, withPassword: pass)
        }
    }
    
    // MARK: - Authenticate User
    private func authenticateUser(withEmail email: String, withPassword pass: String) {
        AuthService.instance.loginUser(withEmail: email, andPassword: pass) { (success, loginError) in
            if success {
                self.successfulLoginAlert()
                self.completeSignIn(id: (authRef.currentUser?.uid)!) // collects uid/keychain when user signs in
                Defaults.setIsLoggedIn(value: true)
                let feedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
                self.present(feedVC, animated:true)
                return
            }
            
            if let loginError = loginError {
                Auth.auth().handleFireAuthError(error: loginError, vc: self)
                print(String(describing: loginError.localizedDescription))
                return
            }
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.presentingViewController?.present(signUpVC, animated:true)
    }
    
    @IBAction func loginAnonymousBtnClicked(_ sender: UIButton) {
        // Check for auth user first, then sign in anony
        if Auth.auth().currentUser == nil {
            authRef.signInAnonymously{ (authResult, error) in
                if error == nil {
                    // successful Anonymous login, segue to FeedViewController
                    let user = authResult?.user
                    let uid = user?.uid
                    self.completeSignIn(id: uid!) // firebase anonymous uid?
                    let feedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
                    self.present(feedVC, animated:true)
                } else if let error = error {
                    // anonymous login problems
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func forgotInfoBtnPressed(_ sender: UIButton) {
        // segue to ForgotPassVC
    }
    
    // MARK: - Keyboard Functions
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Keyboard Dismiss
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Save User Text
    @objc func saveToUserDefaults(_ sender: UITextField) {
        guard defaultsKey != "" else { return }
        Defaults.set(sender.text ?? "", forKey: defaultsKey)
        
        // Defaults.synchronize()
    }
    
    func restoreByUserDefaults() {
        guard defaultsKey != "" else { return }
        guard let text = Defaults.string(forKey: defaultsKey) else { return }
        guard text != "" else { return }
        
        self.text = text
    }
    
    
    // MARK: KeyChain Wrapper Function - storing user data
    func completeSignIn(id: String) {
        let saveSuccessful: Bool = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("Keychain Status: \(saveSuccessful)")
    }
}

// MARK: - Remove SwiftKeyChain
func removeToken() {
    let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
    if removeSuccessful == true {
        print("Token removed")
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextFld {
            self.view.endEditing(true)
        } else {
            passTextFld.becomeFirstResponder()
        }
        return true
    }
}



