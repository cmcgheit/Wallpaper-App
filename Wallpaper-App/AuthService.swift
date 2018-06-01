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
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                // MARK: - Register User/Send Email Verification
                Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                    if (error != nil) {
                        print(error!)
                    }
                })
                guard let user = user else {
                    userCreationComplete(false, error)
                    return
                }
                //            let userData = ["accountType": user.providerID, "email": user.email!, "age": age] as [String: Any] // Register user with data, puts in Dictionary
                //            DataService.instance.createDBUser(uid: user.uid, userData: userData) //.setValue(userData)
                userCreationComplete(true, nil)
        }
    }
    
    // MARK: - Login Function for Existing Users
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if (error != nil) {
                loginComplete(false, error)
                return
            }
            loginComplete(true, nil)
        }
    }
}