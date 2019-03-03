// Wallpaper-App Coded with ♥️ by Carey M

import Firebase

extension Auth {
    func handleFireAuthError(error: Error, vc: UIViewController) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            // sub-class swiftentrykit to use here instead of uialert
            let firErrorAlert = UIAlertController(title: "Error", message: errorCode.errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            firErrorAlert.addAction(okAction)
            vc.present(firErrorAlert, animated: true, completion: nil)
        }
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account. Pick another email"
        case .userNotFound:
            return "User not found with your credentials. Please check your credentials and try again."
        case .userDisabled:
            return "Your account has been disabled. Please contact support"
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error, Please try again"
        case .weakPassword:
            return "Your password is too weak. The password must be at least 6 characters long."
        case .wrongPassword:
            return "Your password is wrong or you have the incorrect email/password combination."
        default:
            return "Sorry, something went wrong. Try Again"
        }
    }
}
