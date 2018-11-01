// Wallpaper-App Coded with ♥️ by Carey M 

import UIKit
import Firebase

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
    
    @IBAction func sendEmailBtnPressed(_ sender: Any) {
        guard let emailText = emailTxtFld.text else { return }
        AuthService.instance.resetEmail(withEmail: emailText, onSuccess: {
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            // error alert
        }
        
    }
    
    @IBAction func resetPassBtnPressed(_ sender: Any) {
        guard let emailText = emailTxtFld.text else { return }
        AuthService.instance.resetPassword(withEmail: emailText, onSuccess: {
            // alert for success?
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            // error Alert
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
