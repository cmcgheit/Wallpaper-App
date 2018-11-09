// SignUpViewController.swift, coded with love by C McGhee

import UIKit
import Firebase
import SwiftEntryKit
import QuickLook

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpTxtFld: UITextField!
    @IBOutlet weak var signUpPassFld: RevealPasswordTextField!
    @IBOutlet weak var signUpBtn: RoundedRectBlueButton!
    @IBOutlet weak var goBackBtn: RoundedRectBlueButton!
    @IBOutlet weak var termsBtn: RoundedRectBlueButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customBackBtn()
        
        signUpTxtFld?.delegate = self
        signUpPassFld?.delegate = self
        
        DispatchQueue.main.async {
            self.signUpBtn?.layer.cornerRadius = 15
            self.goBackBtn?.layer.cornerRadius = 15
            self.termsBtn?.layer.cornerRadius = 15
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: - Notifications
    func notificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: .keyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: .keyboardWillHide, object: nil)
        //        signUpTxtFld?.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange(_:)), for: .editingChanged)
        //        signUpPassFld?.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(keyboardWillShow)
        NotificationCenter.default.removeObserver(keyboardWillHide)
    }
    
    // MARK: - Validation
    func isEmailValid(text: String) -> Bool {
        let regexp = "[A-Z0-9a-z._]+@([\\w\\d]+[\\.\\w\\d]*)"
        return text.evaluate(with: regexp)
    }
    
    func isPassValid(text: String) -> Bool {
        let passReqexp = "^.{6,15}$" // Password length 6-15
        return text.evaluate(with: passReqexp)
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
        let noEmailTitleText = "No Email/Password Entered"
        let noEmailDescText = "Please enter a complete email/password and try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: noEmailTitleText, desc: noEmailDescText, textColor: UIColor.darkGray)
    }
    
    func emailNotValidAlert() {
        let emailNotValidText = "Email Not Valid"
        let emailNotValidDesc = "Please use a valid email address and try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: emailNotValidText, desc: emailNotValidDesc, textColor: UIColor.darkGray)
    }
    
    func passNotValidAlert() {
        let passNotValidText = "Password Not Valid"
        let passNotValidDesc = "Please use a valid password of at least 6 characters"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: passNotValidText, desc: passNotValidDesc, textColor: UIColor.darkGray)
    }
    
    func signInErrorAlert() {
        let signInErrortTitleText = "Error signing in"
        let signInErrorDesc = "Please check that you have entered your email and password correctly and try again"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: signInErrortTitleText, desc: signInErrorDesc, textColor: UIColor.darkGray)
    }
    
    func signUpErrorAlert() {
        let signUpErrorText = "Invalid Email/Password"
        let signUpDescText = "Please check that you have entered a valid email and that your password is at least 6 characters long"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: signUpErrorText, desc: signUpDescText, textColor: UIColor.darkGray)
    }
    
    func signUpSuccessAlert() {
        let signSucText = "Signed Up Successfully"
        let signSucDesc = "Signed Up Successfully, Taking you to Feed"
        self.showNotificationEKMessage(attributes: self.attributesWrapper.attributes, title: signSucText, desc: signSucDesc, textColor: UIColor.darkGray)
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
    
    // MARK: - Authenticate New User
    private func authenticateNewUser(withEmail email: String, withPassword pass: String) {
        // Register New User
        AuthService.instance.registerUser(withEmail: email, andPassword: pass, userCreationComplete: { (success, registrationError) in
            if success { // After registered, login the user
                Analytics.logEvent("user_sign_up", parameters: nil)
                AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, nil) in
                    if registrationError == nil {
                        let feedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
                        self.signUpSuccessAlert()
                        self.present(feedVC, animated:true) // Take user to Feed once sucessfully signed in
                        print("Successfully registered/Signed-In user")
                    } else {
                        if registrationError != nil {
                            // Sign In Error Alert
                            UIView.shake(view: self.signUpTxtFld)
                            UIView.shake(view: self.signUpPassFld)
                            self.signInErrorAlert()
                            print(String(describing: registrationError?.localizedDescription))
                        }
                    }
                })
            }
        })
    }
    
    @IBAction func signUpBtnPressed(_ sender: UIButton) {
        guard let email = signUpTxtFld.text, email.isNotEmpty else { return }
        guard let pass = signUpPassFld.text, pass.isNotEmpty else { return }
        
        if email.isEmpty || pass.isEmpty {
            // MARK: - Empty/No Email/Password entered Alert (not registered)
            UIView.shake(view: signUpTxtFld)
            UIView.shake(view: signUpPassFld)
            noEmailPassAlert()
        } else if email.count > 0 && isEmailValid(text: email) == false {
            UIView.shake(view: signUpTxtFld)
            emailNotValidAlert()
        } else if pass.count > 0 && isPassValid(text: pass) == false {
            UIView.shake(view: signUpPassFld)
            passNotValidAlert()
        } else if email.count > 0 && pass.count > 0 && isEmailValid(text: email) && isPassValid(text: pass) {
            // MARK: - Validate if fields not empty
            authenticateNewUser(withEmail: email, withPassword: pass)
        }
    }
    
    @IBAction func goBackBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func termsBtnPressed(_ sender: UIButton) {
        loadTermsView()
    }
}

extension SignUpViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == signUpTxtFld {
            self.view.endEditing(true)
        } else {
            signUpPassFld.becomeFirstResponder()
        }
        return true
    }
}

extension SignUpViewController: QLPreviewControllerDataSource {
    
    // MARK: - Terms and Conditions
    func loadTermsView() {
        let termsPreview = QLPreviewController()
        termsPreview.dataSource = self
        present(termsPreview, animated: true, completion: nil)
    }
    
    // MARK: - Terms/Preview Controller
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return Bundle.main.url(forResource: "WallVarietyTerms", withExtension: "pdf")! as QLPreviewItem
    }
}
