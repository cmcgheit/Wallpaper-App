//  LoginViewController.swift
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import SwiftEntryKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginCardView: CustomCardView!
    @IBOutlet weak var emailTextFld: UITextField!
    @IBOutlet weak var passTextFld: RevealPasswordTextField!
    @IBOutlet weak var signInBtn: RoundedRectBlueButton!
    @IBOutlet weak var signUpBtn: RoundedRectBlueButton!
    @IBOutlet weak var loginAnBtn: RoundedRectBlueButton!
    @IBOutlet weak var forgotInfoBtn: RoundedRectBlueButton!
    
    // Restore text
    var defaultsKey: String = ""
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInBtn.layer.cornerRadius = 15
        signUpBtn.layer.cornerRadius = 15
        loginAnBtn.layer.cornerRadius = 15
        forgotInfoBtn.layer.cornerRadius = 15
        
        customBackBtn()
        
        emailTextFld.delegate = self
        passTextFld.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificationObservers()
        
        // Take user to Feed if already logged-in
        if Reachability.isConnectedToNetwork() {
            if authRef.currentUser?.uid != nil && authRef.currentUser?.isAnonymous != nil {
                Defaults.setIsLoggedIn(value: true)
                self.performSegue(withIdentifier:  "toFeedViewController", sender: self)
            } else {
                // If User not logged in
                do {
                    try authRef.signOut()
                    return
                } catch  {
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
    
    // MARK: - Attributes Wrapper
    private var attributesWrapper: EntryAttributeWrapper {
        var attributes = EKAttributes.topFloat
        attributes.entryBackground = .color(color: UIColor.white)
        attributes.roundCorners = .all(radius: 10)
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        return EntryAttributeWrapper(with: attributes)
        
    }
    
    // MARK: - SwiftEntryKit Alerts
    // Notification Message
    private func showNotificationEKMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.gillsBoldFont(ofSize: 17), color: UIColor.darkGray))
        let desc = EKProperty.LabelContent(text: desc, style: .init(font: UIFont.gillsRegFont(ofSize: 17), color: UIColor.darkGray))
        let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: desc)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributesWrapper.attributes)
        
    }
    
    func successfulLoginAlert() {
        let successTitleText =  "Successfully Signed In"
        let successDescText = "Taking you to the feed shortly"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: successTitleText, desc: successDescText, textColor: UIColor.darkGray)
    }
    
    func noEmailPassAlert() {
        let noEmailTitleText = "User Not Registered"
        let noEmailDescText = "No email and/or password entered, please enter an email or password and login"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: noEmailTitleText, desc: noEmailDescText, textColor: UIColor.darkGray)
    }
    
    func incorrectEmailPassAlert() {
        let incorrectTitleText = "Incorrect Email/Password"
        let incorrectDescText = "You have entered the incorrect email/password. Please enter your email/password and try again"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: incorrectTitleText, desc: incorrectDescText, textColor: UIColor.darkGray)
    }
    
    func noNetworkAlert() {
        let noNetworkTitle = "No Network Connection"
        let noNetworkDesc = "Please check your network connection, then close and restart the app"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: noNetworkTitle, desc: noNetworkDesc, textColor: UIColor.darkGray)
    }
    
    func anonyLoginError() {
        let anonyErrorTitle = "Anonymous Login Error"
        let anonyErrorDesc = "Check your network connection, restart the app and try to login anonymously again"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: anonyErrorTitle, desc: anonyErrorDesc, textColor: UIColor.darkGray)
    }
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        guard let email = emailTextFld.text, emailTextFld.text != "" else { return }
        guard let pass = passTextFld.text, passTextFld.text != "" else { return }
        
        if email.isNotEmpty && pass.isNotEmpty {
            authenticateUser(withEmail: email, withPassword: pass)
        } else {
            UIView.shake(view: emailTextFld)
            UIView.shake(view: passTextFld)
            noEmailPassAlert()
        }
    }
    
    // MARK: - Authenticate User
    private func authenticateUser(withEmail email: String, withPassword pass: String) {
        AuthService.instance.loginUser(withEmail: email, andPassword: pass) { (success, loginError) in
            if success {
                self.successfulLoginAlert()
                self.completeSignIn(id: (authRef.currentUser?.uid)!) // collects uid/keychain when user signs in
                Defaults.setIsLoggedIn(value: true)
                self.performSegue(withIdentifier: "toFeedViewController", sender: nil)
                return
            }
            
            if loginError != nil {
                self.incorrectEmailPassAlert()
                print(String(describing: loginError?.localizedDescription))
                return
            }
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        // segue to SignUpVC
    }
    
    @IBAction func loginAnonymousBtnClicked(_ sender: UIButton) {
        // Auth user
        authRef.signInAnonymously(completion: { (authResult, error) in
            if error == nil {
                // successful Anonymous login, segue to FeedViewController
                let user = authResult?.user
                let uid = user?.uid
                self.completeSignIn(id: uid!) // firebase anonymous uid?
                self.performSegue(withIdentifier: "toFeedViewController", sender: nil)
            } else if (error != nil) {
                // anonymous login problems
                self.anonyLoginError()
                print(error?.localizedDescription ?? 0)
            }
        }
        )}
    
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextFld {
            self.view.endEditing(true)
        } else {
            passTextFld.becomeFirstResponder()
        }
        return true
    }
}



