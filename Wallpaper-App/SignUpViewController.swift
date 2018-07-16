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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // MARK: - Set navigation bar to transparent
        self.navigationController?.hideTransparentNavigationBar()
        
    }
    
    // MARK - Notifications
    func notificationObservers() {
        
        // NotificationCenter.default.addObserver(self, selector: #selector(, name: , object: nil)
    }
    

    @IBAction func signUpBtnPressed(_ sender: Any) {
        guard let email = signUpTxtFld.text else { return }
        guard let pass = signUpPassFld.text else { return }
        
        
        if email.isEmpty || pass.isEmpty // && textFieldDidChangeAction(notification)
            {
            // MARK: - No Email/Password entered Alert (not registered)
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: UIColor.white)
            attributes.roundCorners = .all(radius: 10)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            
            let titleText = "No Email/Password Entered"
            let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.gillsLightFont(ofSize: 20), color: UIColor.darkGray))
            let descText = "Please enter a complete email/password and try again"
            let description = EKProperty.LabelContent(text: descText, style: .init(font: UIFont.gillsLightFont(ofSize: 17), color: UIColor.darkGray))
            let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35), makeRound: true)
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            
            let contentView = EKNotificationMessageView(with: notificationMessage)
            SwiftEntryKit.display(entry: contentView, using: attributes)
        } else { // Register New User
            AuthService.instance.registerUser(withEmail: email, andPassword: pass, userCreationComplete: { (success, registrationError) in
                if success { // After registered, login the user
                    AuthService.instance.loginUser(withEmail: email, andPassword: pass, loginComplete: { (success, nil) in
                        self.performSegue(withIdentifier: "toFeedViewController", sender: self) // Take user to Feed once sucessfully signed in
                        print("Successfully registered/Signed-In user")
                    })
                } else {
                    var attributes = EKAttributes.topFloat
                    attributes.entryBackground = .color(color: UIColor.white)
                    attributes.roundCorners = .all(radius: 10)
                    attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
                    attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
                    
                    let titleText = "Error signing in"
                    let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.gillsLightFont(ofSize: 20), color: UIColor.darkGray))
                    let descText = "Please check that you have entered your email and password correctly and try again"
                    let description = EKProperty.LabelContent(text: descText, style: .init(font: UIFont.gillsLightFont(ofSize: 17), color: UIColor.darkGray))
                    let image = EKProperty.ImageContent(image: UIImage(named: "exclaimred")!, size: CGSize(width: 35, height: 35), makeRound: true)
                    let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
                    let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
                    
                    let contentView = EKNotificationMessageView(with: notificationMessage)
                    SwiftEntryKit.display(entry: contentView, using: attributes)
                    print(String(describing: registrationError?.localizedDescription))
                }
            })
        }
    }
    
    @IBAction func goBackBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
