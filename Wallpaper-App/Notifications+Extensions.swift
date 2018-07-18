//Wallpaper-App Coded with ♥️ by Carey M 

import Foundation

extension Notification.Name {
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    static let textFieldDidChange = NSNotification.Name(rawValue: "UserTypingTextfield")
    static let saveTextInField = NSNotification.Name(rawValue: "SaveUserText")
    static let firstTimeViewController = NSNotification.Name(rawValue: "firstTimeUserVC")
    static let darkModeEnabled = Notification.Name("com.cmcgheit.wallvariety.notifications.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("com.cmcgheit.wallvariety.notifications.darkModeDisabled")
    
}

