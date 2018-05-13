//Wallpaper-App Coded with ♥️ by: Carey M 

import Foundation

extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case isLoggedIn
        case anonymousLoggedIn
    }
    
    func setAnonymousLogin(value: Bool) {
        set(value, forKey: UserDefaultKeys.anonymousLoggedIn.rawValue)
        synchronize()
    }
    
    func viewLogin() -> Bool {
        return bool(forKey: UserDefaultKeys.anonymousLoggedIn.rawValue)
        
    }
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    }
}
