//  LoginViewController.swift
//
//  Created by C McGhee on 10/10/17.
//  Copyright © 2017 C McGhee. All rights reserved.

import UIKit
import Firebase
import SwiftEntryKit
// import KeychainSwift//SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginCardView: CustomCardView!
    @IBOutlet weak var emailTextFld: AnimatedTextField!
    @IBOutlet weak var passTextFld: RevealPasswordTextField!
    @IBOutlet weak var signInBtn: RoundedRectBlueButton!
    @IBOutlet weak var signUpBtn: RoundedRectBlueButton!
    @IBOutlet weak var loginAnBtn: RoundedRectBlueButton!
    
    // Restore text
    var defaultsKey: String = ""
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInBtn.layer.cornerRadius = 15
        signUpBtn.layer.cornerRadius = 15
        loginAnBtn.layer.cornerRadius = 15
        
        notificationObservers()
        customBackBtn()
        self.enableUnoccludedTextField()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidChange(_:)),
                                               name: Notification.Name.UITextFieldTextDidChange,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: - Set navigation bar to transparent
        self.navigationController?.hideTransparentNavigationBar()
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.disableUnoccludedTextField()
    }
    
    // MARK: - Notifications
    func notificationObservers() {
        
        emailTextFld.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), for: .editingChanged)
        passTextFld.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), for: .editingChanged)
        emailTextFld.addTarget(self, action: #selector(saveToUserDefaults(_:)), for: .editingDidEnd)
        
    }
    
    func removeNotifications() {
        
        NotificationCenter.default.removeObserver(Notification.Name.UITextFieldTextDidChange)
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
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        guard let email = emailTextFld.text else { return }
        guard let pass = passTextFld.text else { return }
        
        if email == "" && pass == "" {
            // MARK: - No Email/Password entered Alert (not registered)
            let titleText = "User Not Registered"
            let descText = "No email and/or password entered, please enter an email or password and login"
            showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
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
                    let titleText = "Incorrect Email/Password"
                    let descText = "You have entered the incorrect email/password. Please enter your email/password and try again"
                    self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
                    // Auth.auth().sendPasswordReset(withEmail: email) ask to reset, logic for mutliple incorrect tries?
                    print(String(describing: loginError?.localizedDescription))
                    // Take User to SignUp if not a registered user
                }
            })
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
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
    
    // MARK: - TextField Change Function
    @objc func textFieldDidChange(_ textField: AnimatedTextField) {
        if emailTextFld.text == "" && passTextFld.text == "" {
            // Empty
        } else {
            // Text has been changed
            NotificationCenter.default.post(name: .textFieldDidChange, object: nil)
        }
    }
    
    // MARK: - Save User Text
    @objc func saveToUserDefaults(_ sender: AnimatedTextField) {
        guard defaultsKey != "" else { return }
        UserDefaults.standard.set(sender.text ?? "", forKey: defaultsKey)

        // UserDefaults.standard.synchronize()
    }
    
    func restoreByUserDefaults() {
        guard defaultsKey != "" else { return }
        guard let text = UserDefaults.standard.string(forKey: defaultsKey) else { return }
        guard text != "" else { return }
        
        self.text = text
    }
    
    
    //// MARK: KeyChain Wrapper Function - storing user data
    //func completeSignIn(id: String) {
    //    let saveSuccessful: Bool = KeychainWrapper.standard.set(id, forKey: KEY_UID)
    //    print("Keychain Status: \(saveSuccessful)")
    //    // Take user to feed once stored keychain wrapper
    //    performSegue(withIdentifier: SegueIdentifier.toStudentVC.rawValue, sender: self)
    //}
}



