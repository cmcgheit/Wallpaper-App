//Wallpaper-App Coded with ♥️ by: Carey M 

import Foundation
import Firebase

class AuthService {
    
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    // MARK: - Create/Register New User
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        authRef.createUser(withEmail: email, password: password) { (user, error) in
            
            // MARK: - Register User/Send Email Verification
            authRef.currentUser?.sendEmailVerification(completion: { (error) in
                if (error != nil) {
                    // handle email already in use error
                    print(error!)
                }
            })
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            let userData = ["accountType": user.user.providerID, "email": user.user.email!] as [String: Any] // Register user with data, puts in Dictionary
            FIRService.createDBUser(uid: user.user.uid, userData: userData)
            userCreationComplete(true, nil)
        }
    }
    
    // MARK: - Login Function for Existing Users
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        authRef.signIn(withEmail: email, password: password) { (user, error) in
            if (error != nil) {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
    
    // MARK: - Email Reset Function // sends user an email to update password
    func resetPassword(withEmail: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        authRef.sendPasswordReset(withEmail: withEmail) {
            error in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .userNotFound:
                        // display an alert
                        break
                    case .invalidEmail:
                        // display alert
                        break
                    default:
                        break
                    }
                }
                return
            }
            onSuccess()
        }
    }
    
    // MARK: - Reset Email Function
    func resetEmail(withEmail: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        authRef.currentUser?.updateEmail(to: withEmail, completion: { (error) in
            if error != nil {
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                    case .invalidEmail:
                        // display alert
                        break
                    case .missingEmail:
                        // display alert
                        break
                    default:
                        break
                    }
                }
                return
            }
            onSuccess()
        })
    }
    
    // MARK - Logout User from Firebase Function
    func logOutUser() {
        do {
            try authRef.signOut()
        } catch let error {
            print("Failed to logout user", error)
        }
    }
}
