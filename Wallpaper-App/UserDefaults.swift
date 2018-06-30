//Wallpaper-App Coded with ♥️ by: Carey M 

import Foundation

extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case isLoggedIn
        case anonymousLoggedIn
        case darkTheme
        case lightTheme
        case instructions
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
    
    func setTheme(value: Bool) {
        set(value, forKey: UserDefaultKeys.lightTheme.rawValue)
        set(value, forKey: UserDefaultKeys.darkTheme.rawValue)
    }
    
    func lightTheme() -> Bool {
        return bool(forKey: UserDefaultKeys.lightTheme.rawValue)
    }
    
    func darkTheme() -> Bool {
        return bool(forKey: UserDefaultKeys.darkTheme.rawValue)
    }
    
    func setInstructions(value: Bool) {
        set(value, forKey: UserDefaultKeys.instructions.rawValue)
    }
    
    func showInstructions() -> Bool {
        return bool(forKey: UserDefaultKeys.instructions.rawValue)
    }
    
    func dontShowInstructions() -> Bool {
        return bool(forKey: UserDefaultKeys.instructions.rawValue)
    }

}
