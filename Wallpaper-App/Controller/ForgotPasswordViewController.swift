// Wallpaper-App Coded with ♥️ by Carey M 

import UIKit
import Firebase
import SwiftEntryKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet fileprivate var forgotView: CustomCardView!
    @IBOutlet fileprivate var emailTxtFld: UITextField!
    @IBOutlet fileprivate var emailPassBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var resetPassBtn: RoundedRectBlueButton!
    @IBOutlet fileprivate var backBtn: RoundedRectBlueButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailPassBtn.layer.cornerRadius = 15
        resetPassBtn.layer.cornerRadius = 15
        backBtn.layer.cornerRadius = 16
        emailTxtFld.becomeFirstResponder()
        
    }
    
    // MARK: - Individual Alerts
    func errorResetEmailAlert() {
        let errorEmResTitle = "Error resetting email"
        let errorEmResDesc = "Try entering your email and resetting again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: errorEmResTitle, desc: errorEmResDesc, textColor: .darkGray)
    }
    
    func errorResetPassAlert() {
        let passResTitle = "Error resetting password"
        let passResDesc = "Try entering your password and resetting again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: passResTitle, desc: passResDesc, textColor: .darkGray)
    }
    
    @IBAction func sendEmailBtnPressed(_ sender: Any) {
        guard let emailText = emailTxtFld.text else { return }
        AuthService.instance.resetEmail(withEmail: emailText, onSuccess: {
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.errorResetEmailAlert()
        }
    }
    
    @IBAction func resetPassBtnPressed(_ sender: Any) {
        guard let emailText = emailTxtFld.text else { return }
        AuthService.instance.resetPassword(withEmail: emailText, onSuccess: {
            // alert for success?
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.errorResetPassAlert()
        }
    }
    
    @IBAction func backbtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Dismiss
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
