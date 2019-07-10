// SignUpViewController.swift, coded with love by C McGhee

import UIKit
import Firebase
// import AuthenticationServices // sign in with Apple (iOS 13)
import SwiftEntryKit
import QuickLook

class SignUpViewController: UIViewController {
    
    @IBOutlet fileprivate var signUpTxtFld: UITextField!
    @IBOutlet fileprivate var signUpPassFld: RevealPasswordTextField!
    @IBOutlet fileprivate var signUpBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var goBackBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var termsBtn: RoundedRectBlueButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customBackBtn()
        setupSOAppleSignIn()
        
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
    
    // MARK: - Individual Alerts
    func noEmailPassAlert() {
        let noEmailTitleText = "No Email/Password Entered"
        let noEmailDescText = "Please enter a complete email/password and try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: noEmailTitleText, desc: noEmailDescText, textColor: .darkGray)
    }
    
    func emailNotValidAlert() {
        let emailNotValidText = "Email Not Valid"
        let emailNotValidDesc = "Please use a valid email address and try again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: emailNotValidText, desc: emailNotValidDesc, textColor: .darkGray)
    }
    
    func passNotValidAlert() {
        let passNotValidText = "Password Not Valid"
        let passNotValidDesc = "Please use a valid password of at least 6 characters"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: passNotValidText, desc: passNotValidDesc, textColor: .darkGray)
    }
    
    func signUpSuccessAlert() {
        let signSucText = "Signed Up Successfully"
        let signSucDesc = "Signed Up Successfully, Taking you to Feed"
        self.showBannerNotificationMessage(attributes: attributesWrapper.attributes, text: signSucText, desc: signSucDesc, textColor: .darkGray)
    }
    
    // MARK: - Keyboard Functions
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
    
    // MARK: - Sign in With Apple Function
    func setupSOAppleSignIn() {
        //
        //        let btnAuthorization = ASAuthorizationAppleIDButton()
        //
        //        btnAuthorization.frame = CGRect(x: 0, y: 0, width: 200, height: 40) // set up for app
        //
        //        btnAuthorization.center = self.view.center
        //
        //        btnAuthorization.addTarget(self, action: #selector(actionHandleAppleSignin), for: .touchUpInside)
        //
        //        self.view.addSubview(btnAuthorization)
        
    }
    
    @objc func actionHandleAppleSignin() {
        
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//
//        let request = appleIDProvider.createRequest()
//
//        request.requestedScopes = [.fullName, .email]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//
//        authorizationController.delegate = self
//
//        authorizationController.presentationContextProvider = self
//
//        authorizationController.performRequests()
        
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
                        if let registrationError = registrationError {
                            // Sign In Error Alert
                            UIView.shake(view: self.signUpTxtFld)
                            UIView.shake(view: self.signUpPassFld)
                            Auth.auth().handleFireAuthError(error: registrationError, vc: self)
                            print(String(describing: registrationError.localizedDescription))
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
    
    // MARK: - Button to Link Anony User to Email User
    @IBAction func turnAnonyUserIntoEmail(_ sender: UIButton) {
        //        guard let authUser = authRef.currentUser else { return }
        //        guard let email = signUpEmail.text else { return }
        //        guard let pass = signUpPass.text else { return }
        //
        //        let credential = EmailAuthProvider.credential(withEmail: email, password: pass)
        //
        //        authUser.linkAndRetrieveData(with: credential) { (linkResult, error) in
        //            if let error = error {
        //                debugPrint(error)
        //                return
        //            }
        //        }
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

// MARK: - Sign in With Apple Extension (make sure to add to app develop account when implement)
//extension SignUpViewController: ASAuthorizationControllerDelegate {
//
//    // ASAuthorizationControllerDelegate function for authorization failed
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//
//        print(error.localizedDescription)
//
//    }
//
//    // ASAuthorizationControllerDelegate function for successful authorization
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//
//            // Create an account as per your requirement
//
//            let appleId = appleIDCredential.user
//
//            let appleUserFirstName = appleIDCredential.fullName?.givenName
//
//            let appleUserLastName = appleIDCredential.fullName?.familyName
//
//            let appleUserEmail = appleIDCredential.email
//
//            //Write your code
//
//        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
//
//            let appleUsername = passwordCredential.user
//
//            let applePassword = passwordCredential.password
//
//            //Write your code
//
//        }
//    }
//}
//
//extension SignUpViewController: ASAuthorizationControllerPresentationContextProviding {
//
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//
//        return self.view.window!
//    }
//}
