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
    
    // MARK - Logout User from Firebase Function
    func logOutUser() {
        do {
            try authRef.signOut()
        } catch let error {
            print("Failed to logout user", error)
        }
    }
}
