//SignUpViewController.swift, coded with love by C McGhee

import UIKit
import Firebase
import SwiftEntryKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpTxtFld: AnimatedTextField!
    @IBOutlet weak var signUpPassFld: AnimatedTextField!
    @IBOutlet weak var signUpBtn: RoundedRectBlueButton!
    @IBOutlet weak var goBackBtn: RoundedRectBlueButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpBtn?.layer.cornerRadius = 15
        goBackBtn?.layer.cornerRadius = 15
        
        notificationObservers()
        customBackBtn()
        self.enableUnoccludedTextField()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textFieldDidChange(_:)),
                                               name: Notification.Name.UITextFieldTextDidChange,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // MARK: - Set navigation bar to transparent
        self.navigationController?.hideTransparentNavigationBar()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.disableUnoccludedTextField()
        removeNotifications()
    }
    
    // MARK - Notifications
    func notificationObservers() {
        
        signUpTxtFld?.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange(_:)), for: .editingChanged)
        signUpPassFld?.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange(_:)), for: .editingChanged)
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
    
    func noEmailPassAlert() {
        let titleText = "No Email/Password Entered"
        let descText = "Please enter a complete email/password and try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
    }
    
    func signInErrorAlert() {
        let titleText = "Error signing in"
        let descText = "Please check that you have entered your email and password correctly and try again"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: titleText, desc: descText, textColor: UIColor.darkGray)
    }
    
    // MARK: - TextField Change Function
    @objc func textFieldDidChange(_ textField: AnimatedTextField) {
        if signUpTxtFld.text == "" && signUpPassFld.text == "" {
            // Call only when user types in email/pass field
            noEmailPassAlert()
        } else {
            // Text has been changed
            NotificationCenter.default.post(name: .textFieldDidChange, object: nil)
        }
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        guard let email = signUpTxtFld.text else { return }
        guard let pass = signUpPassFld.text else { return }
        
        
        if email == "" || pass == "" // && textFieldDidChangeAction(notification)
        {
            // MARK: - No Email/Password entered Alert (not registered)
            
        } else { // Register New User
            AuthService.instance.registerUser(withEmail: email, andPassword: pass, userCreationComplete: { (success, registrationError) in
                if success { // After registered, login the user
                    AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, nil) in
                        self.performSegue(withIdentifier: "toFeedViewController", sender: self) // Take user to Feed once sucessfully signed in
                        print("Successfully registered/Signed-In user")
                    })
                } else {
                    // Sign In Error Alert
                    self.signInErrorAlert()
                    print(String(describing: registrationError?.localizedDescription))
                }
            })
        }
    }
    
    @IBAction func goBackBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
