// Wallpaper-App Coded with ♥️ by Carey M 

import UIKit
import Firebase
import SwiftEntryKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var forgotView: CustomCardView!
    @IBOutlet weak var emailTxtFld: UITextField!
    @IBOutlet weak var emailPassBtn: RoundedRectBlueButton!
    @IBOutlet weak var resetPassBtn: RoundedRectBlueButton!
    @IBOutlet weak var backBtn: RoundedRectBlueButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailPassBtn.layer.cornerRadius = 15
        resetPassBtn.layer.cornerRadius = 15
        backBtn.layer.cornerRadius = 16
        emailTxtFld.becomeFirstResponder()
        
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
    
    func errorResetEmailAlert() {
        let errorEmResTitle = "Error resetting email"
        let errorEmResDesc = "Try entering your email and resetting again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: errorEmResTitle, desc: errorEmResDesc, textColor: UIColor.darkGray)
    }
    
    func errorResetPassAlert() {
        let passResTitle = "Error resetting password"
        let passResDesc = "Try entering your password and resetting again"
        showNotificationEKMessage(attributes: attributesWrapper.attributes, title: passResTitle, desc: passResDesc, textColor: UIColor.darkGray)
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
