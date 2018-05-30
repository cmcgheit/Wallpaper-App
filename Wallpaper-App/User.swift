//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation

// User profile can be used for a profile page later
struct User {
    
    let uid: String
    let username: String
    let profileImageURL: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
    }
    
}
